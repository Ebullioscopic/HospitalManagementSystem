import random, string
from django.core.mail import send_mail
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .models import EmailOTP
from hospital.models import Patient, Staff
from rest_framework_simplejwt.tokens import RefreshToken
import json
from rest_framework_simplejwt.views import TokenRefreshView
from django.contrib.auth.hashers import make_password, check_password
from hospital.permissions import IsAdminStaff
from accounts.authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated
import os
def generate_otp(length=6):
    """Generate a random OTP consisting of digits."""
    return ''.join(random.choices(string.digits, k=length))

class InitiateEmailVerification(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        
        if not email:
            return Response({"error": "Email is required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Check if patient already exists with this email
        if Patient.objects.filter(patient_email=email).exists():
            return Response({"error": "Patient with this email already exists."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        otp = generate_otp()
        
        # Update or create OTP record for the email
        otp_record, created = EmailOTP.objects.update_or_create(
            email=email,
            user_type='patient',
            defaults={'otp': otp, 'verified': False}
        )
        
        subject = "Your Email Verification OTP"
        message = f"Your OTP for email verification is: {otp}"
        from_email = settings.EMAIL_HOST_USER if hasattr(settings, "EMAIL_HOST_USER") else 'noreply@example.com'
        recipient_list = [email]
        
        try:
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        except Exception as e:
            return Response({"error": "Failed to send email.", "details": str(e)},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({"message": "OTP sent successfully. Please verify your email."},
                        status=status.HTTP_200_OK)

class VerifyEmailAndCreatePatient(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        otp_provided = request.data.get("otp")
        patient_name = request.data.get("patient_name")
        patient_mobile = request.data.get("patient_mobile")
        password = request.data.get("password")
        
        if not all([email, otp_provided, patient_name, patient_mobile, password]):
            return Response({"error": "Email, OTP, name, mobile, and password are required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Check if patient already exists
        if Patient.objects.filter(patient_email=email).exists():
            return Response({"error": "Patient with this email already exists."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Verify OTP
        try:
            otp_record = EmailOTP.objects.get(email=email, user_type='patient')
        except EmailOTP.DoesNotExist:
            return Response({"error": "OTP not requested for this email."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if otp_record.otp != otp_provided:
            return Response({"error": "Invalid OTP."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Create new patient with password
        patient = Patient.objects.create(
            patient_name=patient_name,
            patient_email=email,
            patient_mobile=patient_mobile
        )
        
        # Set password
        patient.password = make_password(password)
        patient.save()
        
        # Mark OTP as verified
        otp_record.verified = True
        otp_record.save()
        
        # Generate tokens
        refresh = RefreshToken()
        refresh['user_id'] = patient.patient_id
        refresh['user_type'] = 'patient'
        refresh['email'] = email
        
        return Response({
            "message": "Basic registration successful. Please complete your profile.",
            "patient_id": patient.patient_id,
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh)
        }, status=status.HTTP_201_CREATED)

class CompletePatientProfile(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        # Check if authenticated user is a patient
        if not hasattr(request.user, 'patient_id'):
            return Response({"error": "Not a patient account"}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        patient = request.user
        
        # Extract data from request
        dob = request.data.get('patient_dob')
        blood_group = request.data.get('patient_blood_group')
        gender = request.data.get('patient_gender')
        address = request.data.get('patient_address')
        
        if not all([dob, blood_group, gender, address]):
            return Response({"error": "Missing required fields"}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Convert gender string to boolean if needed
        if isinstance(gender, str):
            gender = gender.lower() == 'true' or gender == '1'
            
        # Parse date
        try:
            parsed_dob = datetime.datetime.strptime(dob, '%Y-%m-%d').date()
        except ValueError:
            return Response({"error": "Invalid date format. Use YYYY-MM-DD"}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        # Create patient details
        PatientDetails.objects.create(
            patient=patient,
            patient_dob=parsed_dob,
            patient_gender=gender,
            patient_blood_group=blood_group,
            patient_address=address
        )
        
        return Response({
            "message": "Registration completed successfully",
            "patient_id": patient.patient_id
        }, status=status.HTTP_200_OK)

class UserLogin(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        password = request.data.get("password")
        user_type = request.data.get("user_type", "patient")
        
        if not email or not password:
            return Response({"error": "Email and password are required."},
                           status=status.HTTP_400_BAD_REQUEST)
        
        # Verify user exists and check password
        if user_type == 'patient':
            try:
                user = Patient.objects.get(patient_email=email)
                if not check_password(password, user.password):
                    return Response({"error": "Invalid password."},
                                  status=status.HTTP_401_UNAUTHORIZED)
                user_id = user.patient_id
            except Patient.DoesNotExist:
                return Response({"error": "Patient not found."},
                              status=status.HTTP_404_NOT_FOUND)
        else:  # staff or admin
            try:
                user = Staff.objects.get(staff_email=email)
                if not check_password(password, user.password):
                    return Response({"error": "Invalid password."},
                                  status=status.HTTP_401_UNAUTHORIZED)
                user_id = user.staff_id
                
                # If user type is admin, verify they have admin permissions
                if user_type == 'admin' and not user.role.role_permissions.get('is_admin', False):
                    return Response({"error": "This staff account does not have admin privileges."},
                                  status=status.HTTP_403_FORBIDDEN)
                    
            except Staff.DoesNotExist:
                return Response({"error": "Staff not found."},
                              status=status.HTTP_404_NOT_FOUND)
        
        # Generate and send OTP for second factor
        otp = generate_otp()
        print(otp)
        # Update or create OTP record for the email and user type
        otp_record, created = EmailOTP.objects.update_or_create(
            email=email,
            user_type=user_type,
            defaults={'otp': otp, 'verified': False}
        )
        
        subject = "Your Login Verification OTP"
        message = f"Your OTP for login verification is: {otp}"
        from_email = settings.EMAIL_HOST_USER if hasattr(settings, "EMAIL_HOST_USER") else 'noreply@example.com'
        recipient_list = [email]
        
        try:
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        except Exception as e:
            return Response({"error": "Failed to send email.", "details": str(e)},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "message": "Password verified. OTP sent for two-factor authentication.",
            "user_id": str(user_id),
            "user_type": user_type,
            "requires_otp": True,
            "success": True
        }, status=status.HTTP_200_OK)

class VerifyLoginOTP(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        otp_provided = request.data.get("otp")
        user_type = request.data.get("user_type", "patient")
        
        if not email or not otp_provided:
            return Response({"error": "Email and OTP are required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Verify OTP
        try:
            otp_record = EmailOTP.objects.get(email=email, user_type=user_type)
        except EmailOTP.DoesNotExist:
            return Response({"error": "OTP not requested for this email."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if otp_record.otp != otp_provided:
            return Response({"error": "Invalid OTP."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Get user ID based on user type
        if user_type == 'patient':
            try:
                user = Patient.objects.get(patient_email=email)
                user_id = user.patient_id
            except Patient.DoesNotExist:
                return Response({"error": "Patient not found."},
                              status=status.HTTP_404_NOT_FOUND)
        else:  # staff or admin
            try:
                user = Staff.objects.get(staff_email=email)
                user_id = user.staff_id
            except Staff.DoesNotExist:
                return Response({"error": "Staff not found."},
                              status=status.HTTP_404_NOT_FOUND)
        
        # Mark OTP as verified
        otp_record.verified = True
        otp_record.save()
        
        # Generate tokens
        refresh = RefreshToken()
        refresh['user_id'] = user_id
        refresh['user_type'] = user_type
        refresh['email'] = email
        
        return Response({
            "message": "Login successful.",
            "user_id": str(user_id),
            "user_type": user_type,
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh),
            "success": True
        }, status=status.HTTP_200_OK)


class RequestOTP(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        user_type = request.data.get("user_type", "patient")  # Default to patient
        
        if not email:
            return Response({"error": "Email is required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # For staff login, verify email exists in the system
        if user_type == 'staff':
            if not Staff.objects.filter(staff_email=email).exists():
                return Response({"error": "Staff email not found in the system."},
                                status=status.HTTP_404_NOT_FOUND)
        
        otp = generate_otp()
        print(otp)
        # Update or create OTP record for the email and user type
        otp_record, created = EmailOTP.objects.update_or_create(
            email=email,
            user_type=user_type,
            defaults={'otp': otp, 'verified': False}
        )
        
        subject = "Your Verification OTP"
        message = f"Your OTP for email verification is: {otp}"
        from_email = settings.EMAIL_HOST_USER if hasattr(settings, "EMAIL_HOST_USER") else 'noreply@example.com'
        recipient_list = [email]
        
        try:
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        except Exception as e:
            return Response({"error": "Failed to send email.", "details": str(e), "status": "failed"},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({"message": "OTP sent successfully.", "status" : "success"},
                        status=status.HTTP_200_OK)

# class PatientSignup(APIView):
#     def post(self, request, *args, **kwargs):
#         email = request.data.get("email")
#         otp_provided = request.data.get("otp")
#         patient_name = request.data.get("patient_name")
#         patient_mobile = request.data.get("patient_mobile")
        
#         if not all([email, otp_provided, patient_name, patient_mobile]):
#             return Response({"error": "Email, OTP, name and mobile are required."},
#                             status=status.HTTP_400_BAD_REQUEST)
        
#         # Check if patient already exists
#         if Patient.objects.filter(patient_email=email).exists():
#             return Response({"error": "Patient with this email already exists."},
#                             status=status.HTTP_400_BAD_REQUEST)
        
#         # Verify OTP
#         try:
#             otp_record = EmailOTP.objects.get(email=email, user_type='patient')
#         except EmailOTP.DoesNotExist:
#             return Response({"error": "OTP not requested for this email."},
#                             status=status.HTTP_400_BAD_REQUEST)
        
#         if otp_record.otp != otp_provided:
#             return Response({"error": "Invalid OTP."},
#                             status=status.HTTP_400_BAD_REQUEST)
        
#         # Create new patient
#         patient = Patient.objects.create(
#             patient_name=patient_name,
#             patient_email=email,
#             patient_mobile=patient_mobile
#         )
        
#         # Mark OTP as verified
#         otp_record.verified = True
#         otp_record.save()
        
#         # Generate tokens
#         refresh = RefreshToken()
#         refresh['user_id'] = patient.patient_id
#         refresh['user_type'] = 'patient'
#         refresh['email'] = email
        
#         return Response({
#             "message": "Patient registered successfully.",
#             "patient_id": patient.patient_id,
#             "access_token": str(refresh.access_token),
#             "refresh_token": str(refresh)
#         }, status=status.HTTP_201_CREATED)

class PatientSignup(APIView):
    def post(self, request, *args, **kwargs):
        print(request.data)
        email = request.data.get("email")
        otp_provided = request.data.get("otp")
        patient_name = request.data.get("patient_name")
        patient_mobile = request.data.get("patient_mobile")
        password = request.data.get("password")
        
        if not all([email, otp_provided, patient_name, patient_mobile, password]):
            return Response({"error": "Email, OTP, name, mobile, and password are required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Check if patient already exists
        if Patient.objects.filter(patient_email=email).exists():
            return Response({"error": "Patient with this email already exists."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Verify OTP
        try:
            otp_record = EmailOTP.objects.get(email=email, user_type='patient')
        except EmailOTP.DoesNotExist:
            return Response({"error": "OTP not requested for this email."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if otp_record.otp != otp_provided:
            return Response({"error": "Invalid OTP."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Create new patient with password
        patient = Patient.objects.create(
            patient_name=patient_name,
            patient_email=email,
            patient_mobile=patient_mobile
        )
        patient.set_password(password)
        patient.save()
        
        # Mark OTP as verified
        otp_record.verified = True
        otp_record.save()
        
        # Generate tokens
        refresh = RefreshToken()
        refresh['user_id'] = patient.patient_id
        refresh['user_type'] = 'patient'
        refresh['email'] = email
        
        return Response({
            "message": "Patient registered successfully.",
            "patient_id": str(patient.patient_id),
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh)
        }, status=status.HTTP_201_CREATED)

# class UserLogin(APIView):
#     def post(self, request, *args, **kwargs):
#         email = request.data.get("email")
#         otp_provided = request.data.get("otp")
#         user_type = request.data.get("user_type", "patient")
                
#         if not email or not otp_provided:
#             return Response({"error": "Email and OTP are required."},
#                            status=status.HTTP_400_BAD_REQUEST)
        
#         # Standardize user type
#         token_user_type = user_type
#         db_user_type = "staff" if user_type == "admin" else user_type
        
#         # Verify user exists
#         if db_user_type == 'patient':
#             try:
#                 user = Patient.objects.get(patient_email=email)
#                 user_id = user.patient_id
#             except Patient.DoesNotExist:
#                 return Response({"error": "Patient not found."},
#                               status=status.HTTP_404_NOT_FOUND)
#         else:  # staff or admin
#             try:
#                 user = Staff.objects.get(staff_email=email)
#                 user_id = user.staff_id
                
#                 # If user type is admin, verify they have admin permissions
#                 if user_type == 'admin' and not user.role.role_permissions.get('is_admin', False):
#                     return Response({"error": "This staff account does not have admin privileges."},
#                                   status=status.HTTP_403_FORBIDDEN)
                    
#             except Staff.DoesNotExist:
#                 return Response({"error": "Staff not found."},
#                               status=status.HTTP_404_NOT_FOUND)
        
#         # Verify OTP - look for either the exact user type or the standardized one
#         try:
#             otp_record = EmailOTP.objects.get(email=email, user_type=user_type)
#         except EmailOTP.DoesNotExist:
#             try:
#                 # Try alternative user type
#                 otp_record = EmailOTP.objects.get(email=email, user_type=db_user_type)
#             except EmailOTP.DoesNotExist:
#                 return Response({"error": "OTP not requested for this email."},
#                               status=status.HTTP_400_BAD_REQUEST)
        
#         if otp_record.otp != otp_provided:
#             return Response({"error": "Invalid OTP."},
#                           status=status.HTTP_400_BAD_REQUEST)
        
#         # Mark OTP as verified
#         otp_record.verified = True
#         otp_record.save()
        
#         # Generate tokens with the original user_type as requested by client
#         refresh = RefreshToken()
#         refresh['user_id'] = user_id
#         refresh['user_type'] = token_user_type  # Keep the original user_type (admin or staff)
#         refresh['email'] = email
        
#         return Response({
#             "message": "Login successful.",
#             "user_id": user_id,
#             "user_type": token_user_type,
#             "access_token": str(refresh.access_token),
#             "refresh_token": str(refresh)
#         }, status=status.HTTP_200_OK)
        
# class UserLogin(APIView):
#     def post(self, request, *args, **kwargs):
#         email = request.data.get("email")
#         password = request.data.get("password")
#         user_type = request.data.get("user_type", "patient")
        
#         if not email or not password:
#             return Response({"error": "Email and password are required."},
#                            status=status.HTTP_400_BAD_REQUEST)
        
#         # Standardize user type
#         token_user_type = user_type
#         db_user_type = "staff" if user_type == "admin" else user_type
        
#         # Verify user exists and check password
#         if db_user_type == 'patient':
#             try:
#                 user = Patient.objects.get(patient_email=email)
#                 if not user.check_password(password):
#                     return Response({"error": "Invalid password."},
#                                   status=status.HTTP_401_UNAUTHORIZED)
#                 user_id = user.patient_id
#             except Patient.DoesNotExist:
#                 return Response({"error": "Patient not found."},
#                               status=status.HTTP_404_NOT_FOUND)
#         else:  # staff or admin
#             try:
#                 user = Staff.objects.get(staff_email=email)
#                 if not user.check_password(password):
#                     return Response({"error": "Invalid password."},
#                                   status=status.HTTP_401_UNAUTHORIZED)
#                 user_id = user.staff_id
                
#                 # If user type is admin, verify they have admin permissions
#                 if user_type == 'admin' and not user.role.role_permissions.get('is_admin', False):
#                     return Response({"error": "This staff account does not have admin privileges."},
#                                   status=status.HTTP_403_FORBIDDEN)
                    
#             except Staff.DoesNotExist:
#                 return Response({"error": "Staff not found."},
#                               status=status.HTTP_404_NOT_FOUND)
        
#         # Generate and send OTP for second factor
#         otp = generate_otp()
        
#         # Update or create OTP record for the email and user type
#         otp_record, created = EmailOTP.objects.update_or_create(
#             email=email,
#             user_type=user_type,
#             defaults={'otp': otp, 'verified': False}
#         )
        
#         subject = "Your Login Verification OTP"
#         message = f"Your OTP for login verification is: {otp}"
#         from_email = settings.EMAIL_HOST_USER if hasattr(settings, "EMAIL_HOST_USER") else 'noreply@example.com'
#         recipient_list = [email]
        
#         try:
#             send_mail(subject, message, from_email, recipient_list, fail_silently=False)
#         except Exception as e:
#             return Response({"error": "Failed to send email.", "details": str(e)},
#                             status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
#         return Response({
#             "message": "Password verified. OTP sent for two-factor authentication.",
#             "user_id": user_id,
#             "user_type": token_user_type,
#             "requires_otp": True
#         }, status=status.HTTP_200_OK)

# class VerifyLoginOTP(APIView):
#     def post(self, request, *args, **kwargs):
#         email = request.data.get("email")
#         otp_provided = request.data.get("otp")
#         user_type = request.data.get("user_type", "patient")
        
#         if not email or not otp_provided:
#             return Response({"error": "Email and OTP are required."},
#                             status=status.HTTP_400_BAD_REQUEST)
        
#         # Standardize user type
#         token_user_type = user_type
#         db_user_type = "staff" if user_type == "admin" else user_type
        
#         # Verify user exists
#         if db_user_type == 'patient':
#             try:
#                 user = Patient.objects.get(patient_email=email)
#                 user_id = user.patient_id
#             except Patient.DoesNotExist:
#                 return Response({"error": "Patient not found."},
#                               status=status.HTTP_404_NOT_FOUND)
#         else:  # staff or admin
#             try:
#                 user = Staff.objects.get(staff_email=email)
#                 user_id = user.staff_id
#             except Staff.DoesNotExist:
#                 return Response({"error": "Staff not found."},
#                               status=status.HTTP_404_NOT_FOUND)
        
#         # Verify OTP
#         try:
#             otp_record = EmailOTP.objects.get(email=email, user_type=user_type)
#         except EmailOTP.DoesNotExist:
#             try:
#                 # Try alternative user type
#                 otp_record = EmailOTP.objects.get(email=email, user_type=db_user_type)
#             except EmailOTP.DoesNotExist:
#                 return Response({"error": "OTP not requested for this email."},
#                               status=status.HTTP_400_BAD_REQUEST)
        
#         if otp_record.otp != otp_provided:
#             return Response({"error": "Invalid OTP."},
#                           status=status.HTTP_400_BAD_REQUEST)
        
#         # Mark OTP as verified
#         otp_record.verified = True
#         otp_record.save()
        
#         # Generate tokens with the original user_type as requested by client
#         refresh = RefreshToken()
#         refresh['user_id'] = user_id
#         refresh['user_type'] = token_user_type
#         refresh['email'] = email
        
#         return Response({
#             "message": "Two-factor authentication successful.",
#             "user_id": user_id,
#             "user_type": token_user_type,
#             "access_token": str(refresh.access_token),
#             "refresh_token": str(refresh)
#         }, status=status.HTTP_200_OK)

class VerifyOTP(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        otp_provided = request.data.get("otp")
        
        if not email or not otp_provided:
            return Response({"error": "Email and OTP are required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        try:
            otp_record = EmailOTP.objects.get(email=email)
        except EmailOTP.DoesNotExist:
            return Response({"error": "OTP not requested for this email."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if otp_record.otp == otp_provided:
            otp_record.verified = True
            otp_record.save()
            return Response({"message": "OTP verified successfully."},
                            status=status.HTTP_200_OK)
        else:
            return Response({"error": "Invalid OTP."},
                            status=status.HTTP_400_BAD_REQUEST)
        

# accounts/views.py (add this new view)
from hospital.models import Staff, Role
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import uuid

# class CreateAdminStaffView(APIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAdminStaff]
    
#     def post(self, request, *args, **kwargs):
#         # Extract and validate required fields
#         staff_name = request.data.get('staff_name')
#         staff_email = request.data.get('staff_email')
#         staff_mobile = request.data.get('staff_mobile')
#         role_id = request.data.get('role_id')
#         staff_joining_date = request.data.get('staff_joining_date')
        
#         if not all([staff_name, staff_email, staff_mobile, role_id, staff_joining_date]):
#             return Response({"error": "Missing required fields"}, 
#                           status=status.HTTP_400_BAD_REQUEST)
                          
#         # Check if email already exists
#         if Staff.objects.filter(staff_email=staff_email).exists():
#             return Response({"error": "Staff with this email already exists"}, 
#                           status=status.HTTP_400_BAD_REQUEST)
                          
#         # Verify role exists
#         try:
#             role = Role.objects.get(role_id=role_id)
#         except Role.DoesNotExist:
#             return Response({"error": f"Role with ID {role_id} does not exist"}, 
#                           status=status.HTTP_400_BAD_REQUEST)
                          
#         # Generate unique staff ID
#         staff_id = f"STAFF{uuid.uuid4().hex[:8].upper()}"
#         while Staff.objects.filter(staff_id=staff_id).exists():
#             staff_id = f"STAFF{uuid.uuid4().hex[:8].upper()}"
            
#         # Create the staff
#         staff = Staff.objects.create(
#             staff_id=staff_id,
#             staff_name=staff_name,
#             role=role,
#             staff_joining_date=staff_joining_date,
#             staff_email=staff_email,
#             staff_mobile=staff_mobile
#         )
        
#         # Generate tokens for immediate use
#         from rest_framework_simplejwt.tokens import RefreshToken
#         refresh = RefreshToken()
#         refresh['user_id'] = staff.staff_id
#         refresh['user_type'] = 'staff'
#         refresh['email'] = staff_email
        
#         return Response({
#             "message": "Admin staff created successfully",
#             "staff_id": staff.staff_id,
#             "access_token": str(refresh.access_token),
#             "refresh_token": str(refresh)
#         }, status=status.HTTP_201_CREATED)
    
class CreateAdminStaffView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAdminStaff]
    
    def post(self, request, *args, **kwargs):
        # Extract and validate required fields
        staff_name = request.data.get('staff_name')
        staff_email = request.data.get('staff_email')
        staff_mobile = request.data.get('staff_mobile')
        role_id = request.data.get('role_id')
        staff_joining_date = request.data.get('staff_joining_date')
        password = request.data.get('password')
        
        if not all([staff_name, staff_email, staff_mobile, role_id, staff_joining_date, password]):
            return Response({"error": "Missing required fields"}, 
                          status=status.HTTP_400_BAD_REQUEST)
                          
        # Check if email already exists
        if Staff.objects.filter(staff_email=staff_email).exists():
            return Response({"error": "Staff with this email already exists"}, 
                          status=status.HTTP_400_BAD_REQUEST)
                          
        # Verify role exists
        try:
            role = Role.objects.get(role_id=role_id)
        except Role.DoesNotExist:
            return Response({"error": f"Role with ID {role_id} does not exist"}, 
                          status=status.HTTP_400_BAD_REQUEST)
                          
        # Generate unique staff ID
        staff_id = f"STAFF{uuid.uuid4().hex[:8].upper()}"
        while Staff.objects.filter(staff_id=staff_id).exists():
            staff_id = f"STAFF{uuid.uuid4().hex[:8].upper()}"
            
        # Create the staff with password
        staff = Staff.objects.create(
            staff_id=staff_id,
            staff_name=staff_name,
            role=role,
            created_at=staff_joining_date,
            staff_email=staff_email,
            staff_mobile=staff_mobile
        )
        staff.set_password(password)
        staff.save()
        
        # Generate OTP for initial verification
        otp = generate_otp()
        EmailOTP.objects.create(
            email=staff_email,
            user_type='staff',
            otp=otp,
            verified=False
        )
        
        # Send OTP email
        subject = "Your Staff Account Verification OTP"
        message = f"Your OTP for staff account verification is: {otp}"
        from_email = settings.EMAIL_HOST_USER
        recipient_list = [staff_email]
        
        try:
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        except Exception as e:
            return Response({"error": "Staff created but failed to send OTP email.", "details": str(e)},
                          status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "message": "Admin staff created successfully. OTP sent for verification.",
            "staff_id": staff.staff_id
        }, status=status.HTTP_201_CREATED)

class ChangePasswordView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        
        if not current_password or not new_password:
            return Response({"error": "Current and new passwords are required."},
                          status=status.HTTP_400_BAD_REQUEST)
        
        user = request.user
        
        # Check if user is patient or staff
        if hasattr(user, 'patient_id'):
            if not user.check_password(current_password):
                return Response({"error": "Current password is incorrect."},
                              status=status.HTTP_400_BAD_REQUEST)
            user.set_password(new_password)
            user.save()
        elif hasattr(user, 'staff_id'):
            if not user.check_password(current_password):
                return Response({"error": "Current password is incorrect."},
                              status=status.HTTP_400_BAD_REQUEST)
            user.set_password(new_password)
            user.save()
        else:
            return Response({"error": "Invalid user type."},
                          status=status.HTTP_400_BAD_REQUEST)
        
        return Response({"message": "Password changed successfully."},
                      status=status.HTTP_200_OK)

# accounts/views.py (Add these views to your existing file)

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from django.shortcuts import get_object_or_404
from .models import EmailOTP
from hospital.models import Patient, PatientDetails
from .authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated
import datetime

class PatientProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get(self, request, *args, **kwargs):
        # Check if authenticated user is a patient
        if not hasattr(request.user, 'patient_id'):
            return Response({"error": "Not a patient account"}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        patient = request.user
        patient_data = {
            "patient_id": patient.patient_id,
            "patient_name": patient.patient_name,
            "patient_email": patient.patient_email,
            "patient_mobile": patient.patient_mobile,
            "patient_remark": patient.patient_remark
        }

        # Get additional patient details if they exist
        try:
            details = patient.details
            patient_data.update({
                "patient_dob": details.patient_dob,
                "patient_gender": details.patient_gender,
                "patient_blood_group": details.patient_blood_group,
                "patient_address": details.patient_address
            })
            # Fix the duplicated https:// issue
            if details.profile_photo:
                photo_url = details.profile_photo.url
                if photo_url.startswith(('http://', 'https://')):
                    # URL is already absolute, use it as is
                    patient_data["profile_photo"] = photo_url
                else:
                    # URL is relative, build absolute URL
                    patient_data["profile_photo"] = request.build_absolute_uri(photo_url)
            else:
                patient_data["profile_photo"] = None
        except PatientDetails.DoesNotExist:
            # No additional details exist yet
            pass
            
        return Response(patient_data, status=status.HTTP_200_OK)

# class UpdatePatientProfileView(APIView):
#     authentication_classes = [JWTAuthentication]
#     permission_classes = [IsAuthenticated]
#     parser_classes = [MultiPartParser, FormParser]
    
#     def put(self, request, *args, **kwargs):
#         # Check if authenticated user is a patient
#         if not hasattr(request.user, 'patient_id'):
#             return Response({"error": "Not a patient account"}, 
#                           status=status.HTTP_403_FORBIDDEN)
        
#         patient = request.user
        
#         # Extract data from request
#         dob = request.data.get('patient_dob')
#         blood_group = request.data.get('patient_blood_group')
#         gender = request.data.get('patient_gender')
#         address = request.data.get('patient_address')
        
#         if not all([dob, blood_group, gender, address]):
#             return Response({"error": "Missing required fields"}, 
#                           status=status.HTTP_400_BAD_REQUEST)
        
#         # Convert gender string to boolean if needed
#         if isinstance(gender, str):
#             gender = gender.lower() == 'true' or gender == '1'
            
#         # Parse date
#         try:
#             parsed_dob = datetime.datetime.strptime(dob, '%Y-%m-%d').date()
#         except ValueError:
#             return Response({"error": "Invalid date format. Use YYYY-MM-DD"}, 
#                           status=status.HTTP_400_BAD_REQUEST)
        
#         # Update or create patient details
#         patient_details, created = PatientDetails.objects.update_or_create(
#             patient=patient,
#             defaults={
#                 'patient_dob': parsed_dob,
#                 'patient_gender': gender,
#                 'patient_blood_group': blood_group,
#                 'patient_address': address,
#             }
#         )
        
#         return Response({
#             "message": "Profile updated successfully",
#             "created": created,
#             "success": True,
#         }, status=status.HTTP_200_OK)

class UpdatePatientProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    
    def put(self, request, *args, **kwargs):
        # Check if authenticated user is a patient
        if not hasattr(request.user, 'patient_id'):
            return Response({"error": "Not a patient account"}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        patient = request.user
        
        # Extract data from request
        patient_name = request.data.get('patient_name')
        patient_mobile = request.data.get('patient_mobile')
        dob = request.data.get('patient_dob')
        blood_group = request.data.get('patient_blood_group')
        gender = request.data.get('patient_gender')
        address = request.data.get('patient_address')
        
        # Update patient fields
        if patient_name:
            patient.patient_name = patient_name
        
        if patient_mobile:
            # Check if mobile number is already in use by another patient
            if Patient.objects.filter(patient_mobile=patient_mobile).exclude(patient_id=patient.patient_id).exists():
                return Response({"error": "Mobile number already in use"}, 
                              status=status.HTTP_400_BAD_REQUEST)
            patient.patient_mobile = patient_mobile
        
        # Save patient model changes
        patient.save()
        
        # Handle patient details
        patient_details_data = {}
        
        if dob:
            # Parse date
            try:
                parsed_dob = datetime.datetime.strptime(dob, '%Y-%m-%d').date()
                patient_details_data['patient_dob'] = parsed_dob
            except ValueError:
                return Response({"error": "Invalid date format. Use YYYY-MM-DD"}, 
                              status=status.HTTP_400_BAD_REQUEST)
        
        if gender is not None:
            # Convert gender string to boolean if needed
            if isinstance(gender, str):
                gender = gender.lower() == 'true' or gender == '1' or gender.lower() == 'male'
            patient_details_data['patient_gender'] = gender
        
        if blood_group:
            patient_details_data['patient_blood_group'] = blood_group
            
        if address:
            patient_details_data['patient_address'] = address
        
        # Only update PatientDetails if we have data to update
        if patient_details_data:
            # Update or create patient details
            patient_details, created = PatientDetails.objects.update_or_create(
                patient=patient,
                defaults=patient_details_data
            )
        else:
            created = False
        
        return Response({
            "message": "Profile updated successfully",
            "created": created,
            "success": True,
        }, status=status.HTTP_200_OK)

class UpdatePatientPhotoView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    
    # def put(self, request, *args, **kwargs):
    #     # Check if authenticated user is a patient
    #     if not hasattr(request.user, 'patient_id'):
    #         return Response({"error": "Not a patient account"}, 
    #                       status=status.HTTP_403_FORBIDDEN)
        
    #     patient = request.user
        
    #     # Check if image is provided
    #     if 'profile_photo' not in request.FILES:
    #         return Response({"error": "No profile photo provided"}, 
    #                       status=status.HTTP_400_BAD_REQUEST)
        
    #     profile_photo = request.FILES['profile_photo']
        
    #     # Update or create patient details
    #     patient_details, created = PatientDetails.objects.update_or_create(
    #         patient=patient,
    #         defaults={'profile_photo': profile_photo}
    #     )
        
    #     return Response({
    #         "message": "Profile photo updated successfully",
    #         "photo_url": request.build_absolute_uri(patient_details.profile_photo.url)
    #     }, status=status.HTTP_200_OK)
    
    def put(self, request, *args, **kwargs):
        # Check if authenticated user is a patient
        if not hasattr(request.user, 'patient_id'):
            return Response({"error": "Not a patient account"}, 
                        status=status.HTTP_403_FORBIDDEN)
        
        patient = request.user
        
        # Check if image is provided
        if 'profile_photo' not in request.FILES:
            return Response({"error": "No profile photo provided"}, 
                        status=status.HTTP_400_BAD_REQUEST)
        
        profile_photo = request.FILES['profile_photo']
        
        # Generate a unique filename
        original_name = profile_photo.name
        file_extension = os.path.splitext(original_name)[1]
        unique_filename = f"patient_{patient.patient_id}_{uuid.uuid4().hex}{file_extension}"
        profile_photo.name = unique_filename
        
        # Update or create patient details
        patient_details, created = PatientDetails.objects.update_or_create(
            patient=patient,
            defaults={'profile_photo': profile_photo}
        )
        
        # Force refresh the URL by accessing it after save
        patient_details.refresh_from_db()
        
        return Response({
            "message": "Profile photo updated successfully",
            "photo_url": request.build_absolute_uri(patient_details.profile_photo.url)
        }, status=status.HTTP_200_OK)

class VerifyEmailExists(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        user_type = request.data.get("user_type", "patient")
        
        if not email:
            return Response({"error": "Email is required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Check if user exists based on user_type
        if user_type == 'patient':
            exists = Patient.objects.filter(patient_email=email).exists()
        else:  # staff or admin
            exists = Staff.objects.filter(staff_email=email).exists()
        
        if not exists:
            return Response({"error": f"No {user_type} account found with this email."},
                            status=status.HTTP_404_NOT_FOUND)
        
        return Response({"message": "Email verified. Please enter your password."},
                        status=status.HTTP_200_OK)

class VerifyPasswordAndSendOTP(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        password = request.data.get("password")
        user_type = request.data.get("user_type", "patient")
        
        if not email or not password:
            return Response({"error": "Email and password are required."},
                           status=status.HTTP_400_BAD_REQUEST)
        
        # Verify user exists and check password
        if user_type == 'patient':
            try:
                user = Patient.objects.get(patient_email=email)
                if not user.check_password(password):
                    return Response({"error": "Invalid password."},
                                  status=status.HTTP_401_UNAUTHORIZED)
                user_id = user.patient_id
            except Patient.DoesNotExist:
                return Response({"error": "Patient not found."},
                              status=status.HTTP_404_NOT_FOUND)
        else:  # staff or admin
            try:
                user = Staff.objects.get(staff_email=email)
                if not user.check_password(password):
                    return Response({"error": "Invalid password."},
                                  status=status.HTTP_401_UNAUTHORIZED)
                user_id = user.staff_id
                
                # If user type is admin, verify they have admin permissions
                if user_type == 'admin' and not user.role.role_permissions.get('is_admin', False):
                    return Response({"error": "This staff account does not have admin privileges."},
                                  status=status.HTTP_403_FORBIDDEN)
                    
            except Staff.DoesNotExist:
                return Response({"error": "Staff not found."},
                              status=status.HTTP_404_NOT_FOUND)
        
        # Generate and send OTP for second factor
        otp = generate_otp()
        
        # Update or create OTP record for the email and user type
        otp_record, created = EmailOTP.objects.update_or_create(
            email=email,
            user_type=user_type,
            defaults={'otp': otp, 'verified': False}
        )
        
        subject = "Your Login Verification OTP"
        message = f"Your OTP for login verification is: {otp}"
        from_email = settings.EMAIL_HOST_USER if hasattr(settings, "EMAIL_HOST_USER") else 'noreply@example.com'
        recipient_list = [email]
        
        try:
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)
        except Exception as e:
            return Response({"error": "Failed to send email.", "details": str(e)},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "message": "Password verified. OTP sent for verification.",
            "user_id": user_id,
            "user_type": user_type,
            "requires_otp": True
        }, status=status.HTTP_200_OK)

class VerifyOTPAndLogin(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get("email")
        otp_provided = request.data.get("otp")
        user_type = request.data.get("user_type", "patient")
        
        if not email or not otp_provided:
            return Response({"error": "Email and OTP are required."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Verify OTP
        try:
            otp_record = EmailOTP.objects.get(email=email, user_type=user_type)
        except EmailOTP.DoesNotExist:
            return Response({"error": "OTP not requested for this email."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        if otp_record.otp != otp_provided:
            return Response({"error": "Invalid OTP."},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Get user ID based on user type
        if user_type == 'patient':
            try:
                user = Patient.objects.get(patient_email=email)
                user_id = user.patient_id
            except Patient.DoesNotExist:
                return Response({"error": "Patient not found."},
                              status=status.HTTP_404_NOT_FOUND)
        else:  # staff or admin
            try:
                user = Staff.objects.get(staff_email=email)
                user_id = user.staff_id
            except Staff.DoesNotExist:
                return Response({"error": "Staff not found."},
                              status=status.HTTP_404_NOT_FOUND)
        
        # Mark OTP as verified
        otp_record.verified = True
        otp_record.save()
        
        # Generate tokens
        refresh = RefreshToken()
        refresh['user_id'] = user_id
        refresh['user_type'] = user_type
        refresh['email'] = email
        
        return Response({
            "message": "Login successful.",
            "user_id": user_id,
            "user_type": user_type,
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh)
        }, status=status.HTTP_200_OK)

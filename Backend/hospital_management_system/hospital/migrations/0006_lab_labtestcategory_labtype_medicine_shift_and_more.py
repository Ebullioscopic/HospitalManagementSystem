# Generated by Django 5.2 on 2025-04-25 08:08

import django.db.models.deletion
import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hospital', '0005_doctortype_doctor_type_remark'),
        ('transactions', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Lab',
            fields=[
                ('lab_id', models.AutoField(primary_key=True, serialize=False)),
                ('lab_name', models.CharField(max_length=255)),
                ('functional', models.BooleanField(default=True)),
            ],
        ),
        migrations.CreateModel(
            name='LabTestCategory',
            fields=[
                ('test_category_id', models.AutoField(primary_key=True, serialize=False)),
                ('test_category_name', models.CharField(max_length=100)),
                ('test_category_remark', models.TextField(blank=True, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='LabType',
            fields=[
                ('lab_type_id', models.AutoField(primary_key=True, serialize=False)),
                ('lab_type_name', models.CharField(max_length=100)),
                ('supported_tests', models.JSONField()),
            ],
        ),
        migrations.CreateModel(
            name='Medicine',
            fields=[
                ('medicine_id', models.AutoField(primary_key=True, serialize=False)),
                ('medicine_name', models.CharField(max_length=255)),
                ('medicine_remark', models.TextField(blank=True, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='Shift',
            fields=[
                ('shift_id', models.AutoField(primary_key=True, serialize=False)),
                ('shift_name', models.CharField(max_length=100)),
                ('start_time', models.TimeField()),
                ('end_time', models.TimeField()),
            ],
        ),
        migrations.CreateModel(
            name='TargetOrgan',
            fields=[
                ('target_organ_id', models.AutoField(primary_key=True, serialize=False)),
                ('target_organ_name', models.CharField(max_length=100)),
                ('target_organ_remark', models.TextField(blank=True, null=True)),
            ],
        ),
        migrations.AddField(
            model_name='appointment',
            name='created_at',
            field=models.DateTimeField(auto_now_add=True, default=django.utils.timezone.now),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='appointment',
            name='tran',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='appointments', to='transactions.transaction'),
        ),
        migrations.CreateModel(
            name='Diagnosis',
            fields=[
                ('diagnosis_id', models.AutoField(primary_key=True, serialize=False)),
                ('diagnosis_data', models.JSONField()),
                ('lab_test_required', models.BooleanField(default=False)),
                ('follow_up_required', models.BooleanField(default=False)),
                ('appointment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='diagnoses', to='hospital.appointment')),
            ],
        ),
        migrations.CreateModel(
            name='FollowUp',
            fields=[
                ('follow_up_id', models.AutoField(primary_key=True, serialize=False)),
                ('follow_up_date', models.DateField()),
                ('follow_up_remarks', models.TextField(blank=True, null=True)),
                ('appointment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='follow_ups', to='hospital.appointment')),
            ],
        ),
        migrations.CreateModel(
            name='LabTestType',
            fields=[
                ('test_type_id', models.AutoField(primary_key=True, serialize=False)),
                ('test_name', models.CharField(max_length=100)),
                ('test_remark', models.TextField(blank=True, null=True)),
                ('test_category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='test_types', to='hospital.labtestcategory')),
                ('test_target_organ', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='test_types', to='hospital.targetorgan')),
            ],
        ),
        migrations.CreateModel(
            name='LabTest',
            fields=[
                ('lab_test_id', models.AutoField(primary_key=True, serialize=False)),
                ('test_datetime', models.DateTimeField()),
                ('test_result', models.JSONField()),
                ('appointment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='lab_tests', to='hospital.appointment')),
                ('lab', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='lab_tests', to='hospital.lab')),
                ('tran', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='lab_tests', to='transactions.transaction')),
                ('test_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='lab_tests', to='hospital.labtesttype')),
            ],
        ),
        migrations.AddField(
            model_name='lab',
            name='lab_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='labs', to='hospital.labtype'),
        ),
        migrations.CreateModel(
            name='Leave',
            fields=[
                ('leave_id', models.AutoField(primary_key=True, serialize=False)),
                ('leave_reason', models.CharField(max_length=255)),
                ('leave_start', models.DateField()),
                ('leave_end', models.DateField()),
                ('leave_remark', models.TextField(blank=True, null=True)),
                ('staff', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='leaves', to='hospital.staff')),
            ],
        ),
        migrations.CreateModel(
            name='Prescription',
            fields=[
                ('prescription_id', models.AutoField(primary_key=True, serialize=False)),
                ('prescription_remarks', models.TextField(blank=True, null=True)),
                ('appointment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prescriptions', to='hospital.appointment')),
            ],
        ),
        migrations.CreateModel(
            name='PrescribedMedicine',
            fields=[
                ('prescribed_medicine_id', models.AutoField(primary_key=True, serialize=False)),
                ('medicine_dosage', models.JSONField(help_text='e.g. {"morning": 1, "evening": 2}')),
                ('fasting_required', models.BooleanField(default=False)),
                ('medicine', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prescribed_medicines', to='hospital.medicine')),
                ('prescription', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prescribed_medicines', to='hospital.prescription')),
            ],
        ),
        migrations.CreateModel(
            name='Schedule',
            fields=[
                ('schedule_id', models.AutoField(primary_key=True, serialize=False)),
                ('schedule_date', models.DateField()),
                ('staff', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='schedules', to='hospital.staff')),
                ('shift', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='schedules', to='hospital.shift')),
            ],
        ),
        migrations.CreateModel(
            name='Slot',
            fields=[
                ('slot_id', models.AutoField(primary_key=True, serialize=False)),
                ('slot_start_time', models.TimeField()),
                ('slot_duration', models.IntegerField(help_text='Duration in minutes')),
                ('slot_remark', models.TextField(blank=True, null=True)),
                ('shift', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='slots', to='hospital.shift')),
            ],
        ),
        migrations.AddField(
            model_name='appointment',
            name='slot',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='appointments', to='hospital.slot'),
        ),
    ]

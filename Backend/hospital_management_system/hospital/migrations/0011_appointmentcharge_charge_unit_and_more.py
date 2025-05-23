# Generated by Django 5.2 on 2025-05-02 09:13

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hospital', '0010_appointmentcharge_labtestcharge_labtest_priority_and_more'),
        ('transactions', '0002_invoicetype_paymentmethod_transactiontype_unit_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='appointmentcharge',
            name='charge_unit',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='appointment_charges', to='transactions.unit'),
        ),
        migrations.AddField(
            model_name='appointmentcharge',
            name='doctor',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='appointment_charges', to='hospital.staff'),
        ),
        migrations.AddField(
            model_name='appointment',
            name='charge',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='appointments', to='hospital.appointmentcharge'),
        ),
        migrations.AddField(
            model_name='labtestcharge',
            name='charge_unit',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='lab_test_charges', to='transactions.unit'),
        ),
        migrations.AddField(
            model_name='labtestcharge',
            name='test',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='charges', to='hospital.labtesttype'),
        ),
    ]

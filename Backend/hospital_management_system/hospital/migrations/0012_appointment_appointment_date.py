# Generated by Django 5.2 on 2025-05-05 04:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hospital', '0011_appointmentcharge_charge_unit_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='appointment',
            name='appointment_date',
            field=models.DateField(null=True),
        ),
    ]

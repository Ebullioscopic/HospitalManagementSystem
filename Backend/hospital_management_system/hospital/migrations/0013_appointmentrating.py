# Generated by Django 5.2 on 2025-05-06 05:50

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hospital', '0012_appointment_appointment_date'),
    ]

    operations = [
        migrations.CreateModel(
            name='AppointmentRating',
            fields=[
                ('rating_id', models.AutoField(primary_key=True, serialize=False)),
                ('rating', models.IntegerField()),
                ('rating_comment', models.TextField(blank=True, null=True)),
                ('appointment', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='ratings', to='hospital.appointment')),
            ],
        ),
    ]

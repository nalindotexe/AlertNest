from django.db import models
from django.utils import timezone

class Incident(models.Model):
    STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('RESOLVED', 'Resolved'),
    ]
    
    text = models.CharField(max_length=500, db_index=True)
    type = models.CharField(max_length=50) # FIRE, MEDICAL, SECURITY
    severity = models.CharField(max_length=50) # HIGH, MEDIUM, LOW
    location = models.CharField(max_length=100)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    epe_score = models.FloatField(default=0.0)
    epe_reason = models.CharField(max_length=255, default="")
    created_at = models.DateTimeField(default=timezone.now)
    resolved_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.type} - {self.location} ({self.status})"

class ChatMessage(models.Model):
    incident = models.ForeignKey(Incident, on_delete=models.CASCADE, related_name='messages')
    sender = models.CharField(max_length=100)
    message = models.TextField()
    timestamp = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.sender}: {self.message[:20]}..."

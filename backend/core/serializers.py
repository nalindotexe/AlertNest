from rest_framework import serializers
from .models import Incident, ChatMessage

class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ['id', 'incident', 'sender', 'message', 'timestamp']
        extra_kwargs = {'incident': {'read_only': True}}

class IncidentSerializer(serializers.ModelSerializer):
    messages = ChatMessageSerializer(many=True, read_only=True)
    
    class Meta:
        model = Incident
        fields = ['id', 'text', 'type', 'severity', 'location', 'status', 'epe_score', 'epe_reason', 'created_at', 'resolved_at', 'messages']

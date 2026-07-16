# ============================================
# SELLOREAI — VALIDATORS
# ============================================

import re
from typing import Dict, Any, Type

class Validator:
    """Validation utilities for SelloreAI"""
    
    @staticmethod
    def validate_schema(data: Dict[str, Any], schema: Dict[str, Type]) -> bool:
        """Validate data against a schema"""
        for field, expected_type in schema.items():
            if field not in data:
                raise ValueError(f"❌ Missing required field: '{field}'")
            if not isinstance(data[field], expected_type):
                raise TypeError(
                    f"❌ Field '{field}' expects {expected_type.__name__}, "
                    f"got {type(data[field]).__name__}"
                )
        return True
    
    @staticmethod
    def validate_string(value: str, min_len: int = 1, max_len: int = 1000) -> bool:
        """Validate string length"""
        if not isinstance(value, str):
            raise TypeError(f"Expected string, got {type(value)}")
        if len(value) < min_len:
            raise ValueError(f"String too short (min: {min_len})")
        if len(value) > max_len:
            raise ValueError(f"String too long (max: {max_len})")
        return True
    
    @staticmethod
    def validate_language(language: str) -> bool:
        """Validate supported language"""
        allowed = ['Hindi', 'English', 'Hinglish']
        if language not in allowed:
            raise ValueError(f"❌ Language must be one of: {allowed}")
        return True
    
    @staticmethod
    def validate_tone(tone: str) -> bool:
        """Validate supported tone"""
        allowed = ['Casual', 'Professional', 'Funny', 'Motivational', 'Emotional']
        if tone not in allowed:
            raise ValueError(f"❌ Tone must be one of: {allowed}")
        return True

    @staticmethod
    def validate_hashtags(hashtags: list, max_count: int = 10) -> bool:
        """Validate hashtags"""
        if not isinstance(hashtags, list):
            raise TypeError("Hashtags must be a list")
        if len(hashtags) > max_count:
            raise ValueError(f"Too many hashtags (max: {max_count})")
        for tag in hashtags:
            if not tag.startswith('#'):
                raise ValueError(f"Hashtag must start with '#': {tag}")
            if len(tag) < 2 or len(tag) > 20:
                raise ValueError(f"Invalid hashtag length: {tag}")
        return True
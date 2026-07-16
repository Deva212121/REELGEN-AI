import os
from dotenv import load_dotenv
from typing import Optional, Dict, Any

class Config:
    """Singleton configuration manager for SelloreAI"""
    
    _instance: Optional['Config'] = None
    
    def __new__(cls) -> 'Config':
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._load_config()
        return cls._instance
    
    def _load_config(self) -> None:
        """Load all environment variables from .env file"""
        load_dotenv()
        
        # API Keys
        self.GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
        self.INSTAGRAM_ACCESS_TOKEN = os.getenv('INSTAGRAM_ACCESS_TOKEN')
        self.FACEBOOK_ACCESS_TOKEN = os.getenv('FACEBOOK_ACCESS_TOKEN')
        self.YOUTUBE_API_KEY = os.getenv('YOUTUBE_API_KEY')
        self.WHATSAPP_API_KEY = os.getenv('WHATSAPP_API_KEY')
        
        # Firebase
        self.FIREBASE_CREDENTIALS = os.getenv('FIREBASE_CREDENTIALS', 'firebase_credentials.json')
        
        # Logging
        self.LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
        self.LOG_FILE = os.getenv('LOG_FILE', 'logs/selloreai.log')
        
        # App
        self.DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
        self.ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
        
        # Defaults
        self.DEFAULT_LANGUAGE = os.getenv('DEFAULT_LANGUAGE', 'Hindi')
        self.DEFAULT_TONE = os.getenv('DEFAULT_TONE', 'Casual')
        self.REEL_DURATION = int(os.getenv('REEL_DURATION', '15'))
    
    def validate(self) -> bool:
        """Check if required environment variables are set"""
        required = ['GEMINI_API_KEY']
        missing = [key for key in required if not getattr(self, key)]
        
        if missing:
            raise ValueError(f"❌ Missing required config: {missing}")
        
        return True
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get any config value by key"""
        return getattr(self, key.upper(), default)
    
    def to_dict(self) -> Dict[str, Any]:
        """Return all config as a dictionary (hides sensitive values)"""
        return {
            'GEMINI_API_KEY': '***' + self.GEMINI_API_KEY[-4:] if self.GEMINI_API_KEY else None,
            'INSTAGRAM_ACCESS_TOKEN': '***' if self.INSTAGRAM_ACCESS_TOKEN else None,
            'FACEBOOK_ACCESS_TOKEN': '***' if self.FACEBOOK_ACCESS_TOKEN else None,
            'LOG_LEVEL': self.LOG_LEVEL,
            'ENVIRONMENT': self.ENVIRONMENT,
            'DEBUG': self.DEBUG
        }
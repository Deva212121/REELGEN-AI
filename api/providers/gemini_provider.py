# api/providers/gemini_provider.py
import os
import google.generativeai as genai
from ..base_provider import BaseProvider
from utils.config import Config


class GeminiProvider(BaseProvider):
    """
    Google Gemini provider implementation.
    
    Uses the google-generativeai library to interact with Gemini models.
    """
    
    def __init__(self):
        self.config = Config()
        self.api_key = self.config.GEMINI_API_KEY
        
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY not set in environment")
        
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel("gemini-2.0-flash")
        self._model_name = "gemini-2.0-flash"
    
    def generate(self, prompt: str, **kwargs) -> str:
        """
        Generate a response from Gemini.
        
        Args:
            prompt: The prompt to send to Gemini.
            **kwargs: Additional parameters (temperature, max_tokens, etc.)
            
        Returns:
            str: Gemini's response text.
        """
        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            raise RuntimeError(f"Gemini generation failed: {e}")
    
    def get_model_name(self) -> str:
        """Get the Gemini model name."""
        return self._model_name
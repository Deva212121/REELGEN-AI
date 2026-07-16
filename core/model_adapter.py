# core/model_adapter.py
from typing import Optional
from api.base_provider import BaseProvider


class ModelAdapter:
    """
    Lightweight model adapter for MVP.
    Routes requests to the appropriate provider.
    """
    
    def __init__(self, provider: Optional[BaseProvider] = None):
        self._provider = provider
    
    def set_provider(self, provider: BaseProvider) -> None:
        """Set the active provider."""
        self._provider = provider
    
    def generate(self, prompt: str, **kwargs) -> str:
        """
        Generate response using the active provider.
        
        Raises:
            ValueError: If no provider is set.
        """
        if not self._provider:
            raise ValueError("No provider set. Call set_provider() first.")
        
        return self._provider.generate(prompt, **kwargs)
    
    def get_model_name(self) -> str:
        """Get the active model name."""
        if not self._provider:
            return "No provider set"
        return self._provider.get_model_name()
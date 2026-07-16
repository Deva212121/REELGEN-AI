# api/base_provider.py
from abc import ABC, abstractmethod

class BaseProvider(ABC):
    """
    Abstract base class for all LLM providers.
    
    Every provider (Gemini, OpenAI, Claude, etc.) must implement this interface.
    This ensures that the ModelAdapter can work with any provider seamlessly.
    """
    
    @abstractmethod
    def generate(self, prompt: str, **kwargs) -> str:
        """
        Generate a response from the LLM.
        
        Args:
            prompt: The prompt to send to the LLM.
            **kwargs: Additional provider-specific parameters.
            
        Returns:
            str: The LLM's response text.
        """
        pass
    
    @abstractmethod
    def get_model_name(self) -> str:
        """
        Get the name of the model being used.
        
        Returns:
            str: The model name (e.g., "gemini-2.0-flash", "gpt-4o").
        """
        pass
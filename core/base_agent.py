# ============================================
# SELLOREAI — BASE AGENT
# ============================================

from abc import ABC, abstractmethod
from datetime import datetime
from typing import Dict, Any, Optional
from utils.logger import logger

class BaseAgent(ABC):
    """
    Base class for all SelloreAI agents.
    Every agent must inherit from this class.
    """
    
    def __init__(self, agent_name: str):
        self.agent_name = agent_name
        self.status = "initialized"
        self.logs = []
        self.execution_time = 0
        self.error = None
        self.metrics = {
            "tokens_used": 0,
            "cost": 0.0,
            "api_calls": 0
        }
        self.logger = logger
        self.logger.info(f"🤖 {agent_name} initialized")
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize agent resources"""
        pass
    
    @abstractmethod
    def process(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process input and return output"""
        pass
    
    @abstractmethod
    def validate(self, data: Dict[str, Any]) -> bool:
        """Validate input/output schema"""
        pass
    
    @abstractmethod
    def save(self, data: Dict[str, Any]) -> bool:
        """Save agent state/data"""
        pass
    
    @abstractmethod
    def next_agent(self) -> Optional[str]:
        """Return next agent name in pipeline"""
        pass
    
    def run(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Execute agent with timing and error handling"""
        start_time = datetime.now()
        self.status = "running"
        self.logger.info(f"🚀 {self.agent_name} starting...")
        
        try:
            if not self.validate(input_data):
                raise ValueError("Invalid input data")
            
            output = self.process(input_data)
            self.save(output)
            
            self.execution_time = (datetime.now() - start_time).total_seconds()
            self.status = "completed"
            
            self.logger.info(f"✅ {self.agent_name} completed in {self.execution_time:.2f}s")
            
            return {
                "status": "success",
                "agent": self.agent_name,
                "output": output,
                "execution_time": f"{self.execution_time:.2f}s",
                "next_agent": self.next_agent(),
                "metrics": self.metrics,
                "logs": self.logs
            }
            
        except Exception as e:
            self.status = "failed"
            self.error = str(e)
            self.logger.error(f"❌ {self.agent_name} failed: {e}")
            
            return {
                "status": "failed",
                "agent": self.agent_name,
                "error": str(e),
                "execution_time": f"{(datetime.now() - start_time).total_seconds():.2f}s",
                "metrics": self.metrics,
                "logs": self.logs
            }
    
    def log(self, message: str, level: str = "info"):
        """Add log entry"""
        self.logs.append({
            "timestamp": datetime.now().isoformat(),
            "level": level,
            "message": message
        })
        getattr(self.logger, level)(message)
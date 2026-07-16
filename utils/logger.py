import logging
import os
from logging.handlers import RotatingFileHandler

class SelloreAI_Logger:
    """Logger for SelloreAI with file and console output"""
    
    def __init__(self, name: str = "selloreai"):
        self.name = name
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)
        
        # Clear old handlers
        self.logger.handlers.clear()
        
        # Create logs folder if not exists
        os.makedirs("logs", exist_ok=True)
        
        # File handler with rotation (10MB per file, keep 5 backups)
        file_handler = RotatingFileHandler(
            "logs/selloreai.log",
            maxBytes=10 * 1024 * 1024,
            backupCount=5
        )
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(logging.Formatter(
            '%(asctime)s | %(levelname)s | %(name)s | %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        ))
        self.logger.addHandler(file_handler)
        
        # Console handler (for terminal output)
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(logging.Formatter(
            '▶ %(levelname)s: %(message)s'
        ))
        self.logger.addHandler(console_handler)
    
    def info(self, message: str):
        self.logger.info(message)
    
    def debug(self, message: str):
        self.logger.debug(message)
    
    def error(self, message: str):
        self.logger.error(message)
    
    def warning(self, message: str):
        self.logger.warning(message)
    
    def critical(self, message: str):
        self.logger.critical(message)


# Default logger instance
logger = SelloreAI_Logger()
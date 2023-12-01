import logging
import json

from service.application.logging.http_status_filter import HttpStatusFilter


class CustomJsonFormatter(logging.Formatter):
    logger = logging.getLogger(__name__)
    def format(self, record):
        log = {
            "timestamp": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger_name": record.name,
            "thread_name": record.threadName,
            "service_name": "a-random-service",
        }

        if hasattr(record, 'httpStatusCode'):
            log['httpStatusCode'] = record.httpStatusCode

        return json.dumps(log)


def setup_logging():
    formatter = CustomJsonFormatter()
    http_status_filter = HttpStatusFilter()

    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    stream_handler.addFilter(http_status_filter)

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(stream_handler)

    loggers_to_override = [logging.getLogger(name) for name in logging.root.manager.loggerDict]

    for logger in loggers_to_override:
        logger.handlers = []
        logger.addHandler(stream_handler)
        logger.propagate = False

    logging.getLogger("uvicorn.access").setLevel(logging.INFO)

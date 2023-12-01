from contextvars import ContextVar
from logging import Filter

http_status_code: ContextVar[str] = ContextVar("http_status_code", default="")
class HttpStatusFilter(Filter):
    def filter(self, record):
        record.httpStatusCode = http_status_code.get()
        return True
from fastapi import Header, HTTPException

from config import settings


def require_admin(x_admin_key: str | None = Header(default=None, alias="X-Admin-Key")) -> None:
    key = (settings.admin_api_key or "").strip()
    if not key:
        raise HTTPException(status_code=503, detail="Admin API is not configured")
    if (x_admin_key or "").strip() != key:
        raise HTTPException(status_code=401, detail="Invalid admin key")

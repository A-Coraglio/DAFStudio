import uvicorn


if __name__ == "__main__":
    uvicorn.run(
        "loader_app:app",
        host="0.0.0.0",
        port=8000,
        # Con watchfiles instalado (requirements.txt) uvicorn usa su reloader
        # nativo, que sí funciona en Windows (el StatReload por defecto no
        # disparaba nunca). reload_dirs acota el watch al código propio.
        reload=True,
        reload_dirs=["apps", "."],
        reload_excludes=[".venv/*", "uploads/*", "__pycache__/*"],
    )

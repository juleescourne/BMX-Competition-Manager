from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = PROJECT_ROOT / "source"
sys.path.insert(0, str(SOURCE_DIR))

from website import create_app  # noqa: E402


def test_login_page_is_available(tmp_path):
    database_path = tmp_path / "test.db"
    app = create_app(
        {
            "TESTING": True,
            "SECRET_KEY": "test-secret",
            "SQLALCHEMY_DATABASE_URI": f"sqlite:///{database_path.as_posix()}",
        }
    )

    client = app.test_client()
    response = client.get("/login")

    assert response.status_code == 200

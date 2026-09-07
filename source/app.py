from website import create_app, db


app = create_app()


@app.teardown_appcontext
def shutdown_session(exception=None):
    db.session.remove()


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)

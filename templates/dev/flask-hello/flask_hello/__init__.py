from flask import Flask


def create_app():
    app = Flask(__name__)

    from .blueprints.home import home_bp

    app.register_blueprint(home_bp)

    from flask import render_template

    @app.errorhandler(404)
    def not_found_error(error):
        return render_template("errors.html", error="Page not found"), 404

    return app

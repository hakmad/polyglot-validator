from setuptools import setup, find_packages


setup(
        name="polyglot_validator",
        packages=find_packages(),
        entry_points={
            "console_scripts": [
                "polyglot_validator=polyglot_validator.main:main"
            ],
        },
)

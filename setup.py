from setuptools import find_packages, setup


def read_requirements(filename: str):
    with open(filename) as requirements_file:
        return [line.strip() for line in requirements_file if line.strip()]


setup(
    name="lilypondedit",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=read_requirements("requirements.txt"),
    python_requires="~=3.11",
)

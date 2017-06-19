from setuptools import setup

setup(
    name = "asv_nix",
    version = "0.0.1",
    author = "Chris Warburton",
    author_email = "chriswarbo@gmail.com",
    description = ("Nix-based environment for Airspeed Velocity"),
    license = "GPLv3+",
    keywords = "asv benchmark nix",
    url = "http://chriswarbo.net/projects/repos/asv-nix.html",
    packages=['asv_nix'],
    long_description="Nix-based environment for Airspeed Velocity",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: GNU General Public License v3 or later",
    ],
)

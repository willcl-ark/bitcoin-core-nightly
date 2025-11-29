A simple demonstration tool for building a robust CI pipeline for Bitcoin Core using CTest and CDash. This setup performs:

- Continuous Builds: Triggered on pull requests and pushes to master for immediate feedback.
- Nightly Builds: Scheduled daily on the master branch for ongoing monitoring.
- Experimental Builds: Manually triggered for ad-hoc testing.

Results are reported to a centralized CDash dashboard at https://my.cdash.org/index.php?project=core, providing visualizations, historical trends, and failure analysis.
This project serves as a proof-of-concept to showcase how CTest and CDash can standardize Bitcoin Core's CI, complementing existing tools like GitHub Actions and Cirrus CI, while aligning with the shift to CMake builds.

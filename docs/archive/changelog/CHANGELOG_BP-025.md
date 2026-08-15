# BP-025 – World hull and trace parity

- Restores the six-node WinQuake box-hull layout and child/plane orientation.
- Aligns recursive hull checking, start-solid/all-solid handling and epsilon boundaries.
- Preserves world-space impact coordinates and plane distances after translated brush traces.
- Adds independent C/Python golden models and 24 MiniLang runtime fixtures across hull and trace suites.

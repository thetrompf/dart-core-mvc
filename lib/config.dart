/// The [config] library.
library config;

abstract class Config {

  factory Config() = _DefaultConfig;

}

class _DefaultConfig implements Config {

  _DefaultConfig();

}

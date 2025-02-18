#!/usr/bin/python3
#
#   smfc.py (C) 2020-2025, Peter Sulyok
#   IPMI fan controller for Super Micro X10-X13 motherboards.
#
import argparse
import atexit
import configparser
import glob
import os
import subprocess
import sys
import syslog
import time
from typing import Callable, List

# Program version string
version_str: str = "3.8.0"


class Log:
    """Log class. This class can send log messages considering different log levels and different outputs"""

    # Configuration parameters.
    log_level: int  # Log level
    log_output: int  # Log output
    msg: Callable[
        [int, str], None
    ]  # Function reference to the log function (based on log output)

    # Constants for log levels.
    LOG_NONE: int = 0
    LOG_ERROR: int = 1
    LOG_CONFIG: int = 2
    LOG_INFO: int = 3
    LOG_DEBUG: int = 4

    # Constants for log outputs.
    LOG_STDOUT: int = 0
    LOG_STDERR: int = 1
    LOG_SYSLOG: int = 2

    def __init__(self, log_level: int, log_output: int) -> None:
        """Initialize Log class with log output and log level.

        Args:
            log_level (int): user defined log level (LOG_NONE, LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
            log_output (int): user defined log output (LOG_STDOUT, LOG_STDERR, LOG_SYSLOG)
        """
        # Setup log configuration.
        if log_level not in {
            self.LOG_NONE,
            self.LOG_ERROR,
            self.LOG_CONFIG,
            self.LOG_INFO,
            self.LOG_DEBUG,
        }:
            raise ValueError(f"Invalid log level value ({log_level})")
        self.log_level = log_level
        if log_output not in {self.LOG_STDOUT, self.LOG_STDERR, self.LOG_SYSLOG}:
            raise ValueError(f"Invalid log output value ({log_output})")
        self.log_output = log_output
        if self.log_output == self.LOG_STDOUT:
            self.msg = self.msg_to_stdout
        elif self.log_output == self.LOG_STDERR:
            self.msg = self.msg_to_stderr
        else:
            self.msg = self.msg_to_syslog
            syslog.openlog("smfc.service", facility=syslog.LOG_DAEMON)

        # Print the configuration out at DEBUG log level.
        if self.log_level >= self.LOG_CONFIG:
            self.msg(Log.LOG_CONFIG, "Logging module was initialized with:")
            self.msg(Log.LOG_CONFIG, f"   log_level = {self.log_level}")
            self.msg(Log.LOG_CONFIG, f"   log_output = {self.log_output}")

    def map_to_syslog(self, level: int) -> int:
        """Map log level to syslog values.

        Args:
            level (int): log level (LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
        Returns:
            int: syslog log level
        """
        syslog_level = syslog.LOG_ERR
        if level in (self.LOG_CONFIG, self.LOG_INFO):
            syslog_level = syslog.LOG_INFO
        elif level == self.LOG_DEBUG:
            syslog_level = syslog.LOG_DEBUG
        return syslog_level

    def level_to_str(self, level: int) -> str:
        """Convert a log level to a string.

        Args:
            level (int): log level (LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
        Returns:
            str: log level string
        """
        string = "NONE"
        if level == self.LOG_ERROR:
            string = "ERROR"
        if level == self.LOG_CONFIG:
            string = "CONFIG"
        if level == self.LOG_INFO:
            string = "INFO"
        elif level == self.LOG_DEBUG:
            string = "DEBUG"
        return string

    def msg_to_syslog(self, level: int, msg: str) -> None:
        """Print a log message to syslog.

        Args:
            level (int): log level (LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
            msg (str): log message
        """
        if level is not self.LOG_NONE:
            if level <= self.log_level:
                syslog.syslog(self.map_to_syslog(level), msg)

    def msg_to_stdout(self, level: int, msg: str) -> None:
        """Print a log message to stdout.

        Args:
            level (int): log level (LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
            msg (str):  log message
        """
        if level is not self.LOG_NONE:
            if level <= self.log_level:
                print(f"{self.level_to_str(level)}: {msg}", flush=True, file=sys.stdout)

    def msg_to_stderr(self, level: int, msg: str) -> None:
        """Print a log message to stderr.

        Args:
            level (int): log level (LOG_ERROR, LOG_CONFIG, LOG_INFO, LOG_DEBUG)
            msg (str):  log message
        """
        if level is not self.LOG_NONE:
            if level <= self.log_level:
                print(f"{self.level_to_str(level)}: {msg}", flush=True, file=sys.stderr)


class Ipmi:
    """IPMI interface class. It can set/get modes of IPMI fan zones and can set IPMI fan levels using ipmitool."""

    log: Log  # Reference to a Log class instance
    command: str  # Full path for ipmitool command.
    fan_mode_delay: float  # Delay time after execution of IPMI set fan mode function
    fan_level_delay: float  # Delay time after execution of IPMI set fan level function
    swapped_zones: bool  # CPU and HD zones are swapped
    remote_parameters: str  # Remote IPMI parameters.

    # Constant values for IPMI fan modes:
    STANDARD_MODE: int = 0
    FULL_MODE: int = 1
    OPTIMAL_MODE: int = 2
    HEAVY_IO_MODE: int = 4

    # Constant values for IPMI fan zones:
    CPU_ZONE: int = 0
    CPU2_ZONE: int = 1

    # Constant values for the results of IPMI operations:
    SUCCESS: int = 0
    ERROR: int = -1

    # Constant values for the configuration parameters.
    CS_IPMI: str = "Ipmi"
    CV_IPMI_COMMAND: str = "command"
    CV_IPMI_FAN_MODE_DELAY: str = "fan_mode_delay"
    CV_IPMI_FAN_LEVEL_DELAY: str = "fan_level_delay"
    CV_IPMI_SWAPPED_ZONES: str = "swapped_zones"
    CV_IPMI_REMOTE_PARAMETERS: str = "remote_parameters"

    def __init__(self, log: Log, config: configparser.ConfigParser) -> None:
        """Initialize the Ipmi class with a log class and with a configuration class.

        Args:
            log (Log): Log class
            config (configparser.ConfigParser): configuration values
        """
        # Set default or read from configuration
        self.log = log
        self.command = config[self.CS_IPMI].get(self.CV_IPMI_COMMAND, "ipmitool")
        self.fan_mode_delay = config[self.CS_IPMI].getint(
            self.CV_IPMI_FAN_MODE_DELAY, fallback=10
        )
        self.fan_level_delay = config[self.CS_IPMI].getint(
            self.CV_IPMI_FAN_LEVEL_DELAY, fallback=2
        )
        self.swapped_zones = config[self.CS_IPMI].getboolean(
            self.CV_IPMI_SWAPPED_ZONES, fallback=False
        )
        self.remote_parameters = config[self.CS_IPMI].get(
            self.CV_IPMI_REMOTE_PARAMETERS, fallback=""
        )

        # Validate configuration
        # Check 1: a valid command can be executed successfully.
        try:
            subprocess.run(
                [self.command, "sdr"],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except FileNotFoundError as e:
            raise e
        # Check 2: fan_mode_delay must be positive.
        if self.fan_mode_delay < 0:
            raise ValueError(f"Negative fan_mode_delay ({self.fan_mode_delay})")
        # Check 3: fan_mode_delay must be positive.
        if self.fan_level_delay < 0:
            raise ValueError(f"Negative fan_level_delay ({self.fan_level_delay})")
        # Print the configuration out at DEBUG log level.
        if self.log.log_level >= self.log.LOG_CONFIG:
            self.log.msg(self.log.LOG_CONFIG, "Ipmi module was initialized with:")
            self.log.msg(
                self.log.LOG_CONFIG, f"   {self.CV_IPMI_COMMAND} = {self.command}"
            )
            self.log.msg(
                self.log.LOG_CONFIG,
                f"   {self.CV_IPMI_FAN_MODE_DELAY} = {self.fan_mode_delay}",
            )
            self.log.msg(
                self.log.LOG_CONFIG,
                f"   {self.CV_IPMI_FAN_LEVEL_DELAY} = {self.fan_level_delay}",
            )
            self.log.msg(
                self.log.LOG_CONFIG,
                f"   {self.CV_IPMI_SWAPPED_ZONES} = {self.swapped_zones}",
            )
            self.log.msg(
                self.log.LOG_CONFIG,
                f"   {self.CV_IPMI_REMOTE_PARAMETERS} = {self.remote_parameters}",
            )

    def get_fan_mode(self) -> int:
        """Get the current IPMI fan mode.

        Returns:
            int: fan mode (ERROR, STANDARD_MODE, FULL_MODE, OPTIMAL_MODE, HEAVY_IO_MODE)

        Raises:
            FileNotFoundError: ipmitool command cannot be found
            ValueError: output of the ipmitool cannot be interpreted/converted
            RuntimeError: ipmitool execution problem in IPMI (e.g. non-root user, incompatible IPMI systems
                or motherboards)
        """
        r: subprocess.CompletedProcess  # result of the executed process
        arguments: List[str]  # Command arguments
        m: int  # fan mode

        # Read the current IPMI fan mode.
        try:
            arguments = [self.command]
            if self.remote_parameters:
                arguments.extend(self.remote_parameters.split())
            arguments.extend(["raw", "0x30", "0x45", "0x00"])
            r = subprocess.run(arguments, check=False, capture_output=True, text=True)
            if r.returncode != 0:
                raise RuntimeError(r.stderr)
            m = int(r.stdout)
        except (FileNotFoundError, ValueError) as e:
            raise e
        return m

    def get_fan_mode_name(self, mode: int) -> str:
        """Get the name of the specified IPMI fan mode.

        Args:
            mode (int): fan mode
        Returns:
            str: name of the fan mode ('ERROR', 'STANDARD MODE', 'FULL MODE', 'OPTIMAL MODE', 'HEAVY IO MODE')
        """
        fan_mode_name: str  # Name of the fan mode

        fan_mode_name = "ERROR"
        if mode == self.STANDARD_MODE:
            fan_mode_name = "STANDARD_MODE"
        elif mode == self.FULL_MODE:
            fan_mode_name = "FULL_MODE"
        elif mode == self.OPTIMAL_MODE:
            fan_mode_name = "OPTIMAL_MODE"
        elif mode == self.HEAVY_IO_MODE:
            fan_mode_name = "HEAVY IO MODE"
        return fan_mode_name

    def set_fan_mode(self, mode: int) -> None:
        """Set the IPMI fan mode.

        Args:
            mode (int): fan mode (STANDARD_MODE, FULL_MODE, OPTIMAL_MODE, HEAVY_IO_MODE)
        """
        arguments: List[str]  # Command arguments

        # Validate mode parameter.
        if mode not in {
            self.STANDARD_MODE,
            self.FULL_MODE,
            self.OPTIMAL_MODE,
            self.HEAVY_IO_MODE,
        }:
            raise ValueError(f"Invalid fan mode value ({mode}).")
        # Call ipmitool command and set the new IPMI fan mode.
        try:
            arguments = [self.command]
            if self.remote_parameters:
                arguments.extend(self.remote_parameters.split())
            arguments.extend(["raw", "0x30", "0x45", "0x01", str(mode)])
            subprocess.run(
                arguments,
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except FileNotFoundError as e:
            raise e
        # Give time for IPMI system/fans to apply changes in the new fan mode.
        time.sleep(self.fan_mode_delay)

    def set_fan_level(self, zone: int, level: int) -> None:
        """Set the IPMI fan level in a specific zone. Raise an exception in case of invalid parameters.

        Args:
            zone (int): fan zone (CPU_ZONE, CPU2_ZONE)
            level (int): fan level in % (0-100)
        """
        arguments: List[str]  # Command arguments

        # Validate zone parameter
        if zone not in {self.CPU_ZONE, self.CPU2_ZONE}:
            raise ValueError(f"Invalid value: zone ({zone}).")
        # Handle swapped zones
        if self.swapped_zones:
            zone = 1 - zone
        # Validate level parameter (must be in the interval [0..100%])
        if level not in range(0, 101):
            raise ValueError(f"Invalid value: level ({level}).")
        # Set the new IPMI fan level in the specific zone
        try:
            arguments = [self.command]
            if self.remote_parameters:
                arguments.extend(self.remote_parameters.split())
            arguments.extend(
                ["raw", "0x30", "0x70", "0x66", "0x01", str(zone), str(level)]
            )
            subprocess.run(
                arguments,
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except FileNotFoundError as e:
            raise e
        # Give time for IPMI and fans to spin up/down.
        time.sleep(self.fan_level_delay)


class FanController:
    """Generic fan controller class for an IPMI zone."""

    # Constant values for temperature calculation
    CALC_MIN: int = 0
    CALC_AVG: int = 1
    CALC_MAX: int = 2

    # Error messages.
    ERROR_MSG_FILE_IO: str = "Cannot read file ({})."

    # Configuration parameters
    log: Log  # Reference to a Log class instance
    ipmi: Ipmi  # Reference to an Ipmi class instance
    ipmi_zone: int  # IPMI zone identifier
    name: str  # Name of the controller
    count: int  # Number of controlled entities
    temp_calc: int  # Calculate of the temperature (0-min, 1-avg, 2-max)
    steps: int  # Discrete steps in temperatures and fan levels
    sensitivity: float  # Temperature change to activate fan controller (C)
    polling: float  # Polling interval to read temperature (sec)
    min_temp: float  # Minimum temperature value (C)
    max_temp: float  # Maximum temperature value (C)
    min_level: int  # Minimum fan level (0..100%)
    max_level: int  # Maximum fan level (0..100%)
    hwmon_path: List[str]  # Paths for hwmon files in sysfs
    hwmon_reserved: set  # Set of reserved hwmon values (excluded from path operations)

    # Measured or calculated attributes
    temp_step: float  # A temperature steps value (C)
    level_step: float  # A fan level step value (0..100%)
    last_time: float  # Last system time we polled temperature (timestamp)
    last_temp: float  # Last measured temperature value (C)
    last_level: int  # Last configured fan level (0..100%)

    # Function variable for selected temperature calculation method
    get_temp_func: Callable[[], float]

    def __init__(
        self,
        log: Log,
        ipmi: Ipmi,
        ipmi_zone: int,
        name: str,
        count: int,
        temp_calc: int,
        steps: int,
        sensitivity: float,
        polling: float,
        min_temp: float,
        max_temp: float,
        min_level: int,
        max_level: int,
        hwmon_path: str,
        hwmon_reserved: set,
    ) -> None:
        """Initialize the FanController class. Will raise an exception in case of invalid parameters.

        Args:
            log (Log): reference to a Log class instance
            ipmi (Ipmi): reference to an Ipmi class instance
            ipmi_zone (int): IPMI zone identifier
            name (str): name of the controller
            count (int): number of controlled entities
            temp_calc (int): calculation of temperature
            steps (int): discrete steps in temperatures and fan levels
            sensitivity (float): temperature change to activate fan controller (C)
            polling (float): polling time interval for reading temperature (sec)
            min_temp (float): minimum temperature value (C)
            max_temp (float): maximum temperature value (C)
            min_level (int): minimum fan level value [0..100%]
            max_level (int): maximum fan level value [0..100%]
            hwmon_path (str): multiple path elements in sys/hwmon files (it could be a multi-line string value)
            hwmon_reserved (set): reserved values in hwmon (excluded from path operations)
        """
        # Save and validate configuration parameters.
        self.log = log
        self.ipmi = ipmi
        self.ipmi_zone = ipmi_zone
        if self.ipmi_zone not in {Ipmi.CPU_ZONE, Ipmi.CPU2_ZONE}:
            raise ValueError("invalid value: ipmi_zone")
        self.name = name
        self.count = count
        if self.count <= 0:
            raise ValueError("count <= 0")
        self.temp_calc = temp_calc
        if self.temp_calc not in {self.CALC_MIN, self.CALC_AVG, self.CALC_MAX}:
            raise ValueError("invalid value: temp_calc")
        self.steps = steps
        if self.steps <= 0:
            raise ValueError("steps <= 0")
        self.sensitivity = sensitivity
        if self.sensitivity <= 0:
            raise ValueError("sensitivity <= 0")
        self.polling = polling
        if self.polling < 0:
            raise ValueError("polling < 0")
        if max_temp < min_temp:
            raise ValueError("max_temp < min_temp")
        self.min_temp = min_temp
        self.max_temp = max_temp
        if max_level < min_level:
            raise ValueError("max_level < min_level")
        self.min_level = min_level
        self.max_level = max_level
        # Set the proper temperature function.
        if self.count == 1:
            self.get_temp_func = self.get_1_temp
        else:
            self.get_temp_func = self.get_avg_temp
            if self.temp_calc == self.CALC_MIN:
                self.get_temp_func = self.get_min_temp
            elif self.temp_calc == self.CALC_MAX:
                self.get_temp_func = self.get_max_temp
        # Build hwmon_path list.
        self.hwmon_reserved = hwmon_reserved
        self.hwmon_path = []
        self.build_hwmon_path(hwmon_path)
        # Check if temperature can be read successfully.
        if self.hwmon_path:
            self.get_temp_func()
        # Initialize calculated and measured values.
        self.temp_step = (max_temp - min_temp) / steps
        self.level_step = (max_level - min_level) / steps
        self.last_temp = 0
        self.last_level = 0
        self.last_time = time.monotonic() - (polling + 1)
        # Print configuration at DEBUG log level.
        if self.log.log_level >= self.log.LOG_CONFIG:
            self.log.msg(
                self.log.LOG_CONFIG, f"{self.name} fan controller was initialized with:"
            )
            self.log.msg(self.log.LOG_CONFIG, f"   ipmi zone = {self.ipmi_zone}")
            self.log.msg(self.log.LOG_CONFIG, f"   count = {self.count}")
            self.log.msg(self.log.LOG_CONFIG, f"   temp_calc = {self.temp_calc}")
            self.log.msg(self.log.LOG_CONFIG, f"   steps = {self.steps}")
            self.log.msg(self.log.LOG_CONFIG, f"   sensitivity = {self.sensitivity}")
            self.log.msg(self.log.LOG_CONFIG, f"   polling = {self.polling}")
            self.log.msg(self.log.LOG_CONFIG, f"   min_temp = {self.min_temp}")
            self.log.msg(self.log.LOG_CONFIG, f"   max_temp = {self.max_temp}")
            self.log.msg(self.log.LOG_CONFIG, f"   min_level = {self.min_level}")
            self.log.msg(self.log.LOG_CONFIG, f"   max_level = {self.max_level}")
            self.log.msg(self.log.LOG_CONFIG, f"   hwmon_path = {self.hwmon_path}")
            self.print_temp_level_mapping()

    def build_hwmon_path(self, hwmon_str: str) -> None:
        """Build hwmon_path[] list for the specific zone."""

        # Convert the string into a list of path elements (respecting multi-line strings and wild characters).
        if hwmon_str:
            if "\n" in hwmon_str:
                self.hwmon_path = hwmon_str.splitlines()
            else:
                self.hwmon_path = hwmon_str.split()
            # Check the size of the hwmon_path[] list.
            if len(self.hwmon_path) != self.count:
                raise ValueError(
                    f"Inconsistent count ({self.count}) and size of hwmon_path ({len(self.hwmon_path)})"
                )
            # Convert wildcard characters if needed and check file existence.
            for i in range(self.count):
                if "?" in self.hwmon_path[i] or "*" in self.hwmon_path[i]:
                    file_names = glob.glob(self.hwmon_path[i])
                    if not file_names:
                        raise ValueError(
                            self.ERROR_MSG_FILE_IO.format(self.hwmon_path[i])
                        )
                    self.hwmon_path[i] = file_names[0]
                if self.hwmon_path[i] not in self.hwmon_reserved:
                    if not os.path.isfile(self.hwmon_path[i]):
                        raise ValueError(
                            self.ERROR_MSG_FILE_IO.format(self.hwmon_path[i])
                        )

    def _get_nth_temp(self, index: int) -> float:
        """Get the temperature of the 'nth' element in the hwmon list. This is an empty implementation."""

    def get_1_temp(self) -> float:
        """Get a single temperature of a controlled entity in the IPMI zone.

        Returns:
            float: single temperature of a controlled entity (C)
        """
        return self._get_nth_temp(0)

    # pylint: disable=R1730
    def get_min_temp(self) -> float:
        """Get the minimum temperature of multiple controlled entities.

        Returns:
            float: minimum temperature of the controlled entities (C)
        """
        minimum: float  # Minimum temperature value
        value: float  # Float value

        # Calculate minimum temperature.
        minimum = 1000.0
        for i in range(self.count):
            value = self._get_nth_temp(i)
            if value < minimum:
                minimum = value
        return minimum

    def get_avg_temp(self):
        """Get the average temperature of the controlled entities in the IPMI zone.

        Returns:
             float: average temperature of the controlled entities (C)
        """
        average: float  # Average temperature
        counter: int  # Value counter

        # Calculate average temperature.
        average = 0.0
        counter = 0
        for i in range(self.count):
            average += self._get_nth_temp(i)
            counter += 1
        return average / counter

    # pylint: disable=R1731
    def get_max_temp(self) -> float:
        """Get the maximum temperature of the controlled entities in the IPMI zone.

        Returns:
             float: maximum temperature of the controlled entities (C)
        """
        maximum: float  # Maximum temperature value
        value: float  # Float value

        # Calculate minimum temperature.
        maximum = -1.0
        for i in range(self.count):
            value = self._get_nth_temp(i)
            if value > maximum:
                maximum = value
        return maximum

    def set_fan_level(self, level: int) -> None:
        """Set the new fan level in an IPMI zone. Can raise exception (ValueError).

        Args:
            level (int): new fan level [0..100]
        Returns:
            int: result (Ipmi.SUCCESS, Ipmi.ERROR)
        """
        return self.ipmi.set_fan_level(self.ipmi_zone, level)

    def callback_func(self) -> None:
        """Call-back function for a child class."""

    def run(self) -> None:
        """Run IPMI zone controller function with the following steps:

        * Step 1: Read current time. If the elapsed time is bigger than the polling time period
          then go to step 2, otherwise return.
        * Step 2: Read the current temperature. If the change of the temperature goes beyond
          the sensitivity limit then go to step 3, otherwise return
        * Step 3: Calculate the current gain and fan level based on the measured temperature
        * Step 4: If the new fan level is different it will be set and logged
        """
        current_time: float  # Current system timestamp (measured)
        current_temp: float  # Current temperature (measured)
        current_level: int  # Current fan level (calculated)
        current_gain: int  # Current gain level (calculated)

        # Step 1: check the elapsed time.
        current_time = time.monotonic()
        if current_time - self.last_time < self.polling:
            return
        self.last_time = current_time
        # Step 2: read temperature and sensitivity gap.
        self.callback_func()
        current_temp = self.get_temp_func()
        self.log.msg(
            self.log.LOG_DEBUG, f"{self.name}: new temperature > {current_temp:.1f}C"
        )
        if abs(current_temp - self.last_temp) < self.sensitivity:
            return
        self.last_temp = current_temp
        # Step 3: calculate gain and fan level.
        if current_temp <= self.min_temp:
            current_gain = 0
            current_level = self.min_level
        elif current_temp >= self.max_temp:
            current_gain = self.steps
            current_level = self.max_level
        else:
            current_gain = int(round((current_temp - self.min_temp) / self.temp_step))
            current_level = (
                int(round(float(current_gain) * self.level_step)) + self.min_level
            )
        # Step 4: the new fan level will be set and logged.
        if current_level != self.last_level:
            self.last_level = current_level
            self.set_fan_level(current_level)
            self.log.msg(
                self.log.LOG_INFO,
                f"{self.name}: new fan level > {current_level}%/{current_temp:.1f}C",
            )

    def print_temp_level_mapping(self) -> None:
        """Print out the user-defined temperature to level mapping value in log DEBUG level."""
        self.log.msg(self.log.LOG_CONFIG, "   Temperature to level mapping:")
        for i in range(self.steps + 1):
            self.log.msg(
                self.log.LOG_CONFIG,
                f"   {i}. [T:{self.min_temp+(i*self.temp_step):.1f}C - "
                f"L:{int(self.min_level + (i * self.level_step))}%]",
            )


class CpuZone(FanController):
    """CPU zone fan control."""

    # Constant values for the configuration parameters.
    CS_CPU_ZONE: str = "CPU zone"
    CS_CPU2_ZONE: str = "CPU2 zone"
    CV_CPU_ZONE_ENABLED: str = "enabled"
    CV_CPU_ZONE_COUNT: str = "count"
    CV_CPU_ZONE_TEMP_CALC: str = "temp_calc"
    CV_CPU_ZONE_STEPS: str = "steps"
    CV_CPU_ZONE_SENSITIVITY: str = "sensitivity"
    CV_CPU_ZONE_POLLING: str = "polling"
    CV_CPU_ZONE_MIN_TEMP: str = "min_temp"
    CV_CPU_ZONE_MAX_TEMP: str = "max_temp"
    CV_CPU_ZONE_MIN_LEVEL: str = "min_level"
    CV_CPU_ZONE_MAX_LEVEL: str = "max_level"
    CV_CPU_ZONE_HWMON_PATH: str = "hwmon_path"

    def __init__(
        self, log: Log, zone: str, ipmi: Ipmi, config: configparser.ConfigParser
    ) -> None:
        """Initialize the CpuZone class and raise exception in case of invalid configuration.

        Args:
            log (Log): reference to a Log class instance
            ipmi (Ipmi): reference to an Ipmi class instance
            config (configparser.ConfigParser): reference to the configuration (default=None)
        """

        # Initialize FanController class.
        super().__init__(
            log,
            ipmi,
            Ipmi.CPU_ZONE if zone == self.CS_CPU_ZONE else Ipmi.CPU2_ZONE,
            zone,
            config[zone].getint(self.CV_CPU_ZONE_COUNT, fallback=1),
            config[zone].getint(
                self.CV_CPU_ZONE_TEMP_CALC, fallback=FanController.CALC_AVG
            ),
            config[zone].getint(self.CV_CPU_ZONE_STEPS, fallback=6),
            config[zone].getfloat(self.CV_CPU_ZONE_SENSITIVITY, fallback=3.0),
            config[zone].getfloat(self.CV_CPU_ZONE_POLLING, fallback=2),
            config[zone].getfloat(self.CV_CPU_ZONE_MIN_TEMP, fallback=30.0),
            config[zone].getfloat(self.CV_CPU_ZONE_MAX_TEMP, fallback=60.0),
            config[zone].getint(self.CV_CPU_ZONE_MIN_LEVEL, fallback=35),
            config[zone].getint(self.CV_CPU_ZONE_MAX_LEVEL, fallback=100),
            config[zone].get(self.CV_CPU_ZONE_HWMON_PATH),
            set(),
        )

    def build_hwmon_path(self, hwmon_str: str) -> None:
        """Build hwmon_path[] list for the CPU zone."""
        path: str  # Path string
        file_names: List[str]  # Result list of glob.glob()

        # If the user specified the hwmon_path= configuration item.
        if hwmon_str:
            # Convert the string into a list of path.
            super().build_hwmon_path(hwmon_str)
        # If the hwmon_path string was not specified it will be created automatically.
        else:
            # Construct hwmon_path with the resolution of wildcard characters.
            self.hwmon_path = []
            for i in range(self.count):
                path = (
                    "/sys/devices/platform/coretemp."
                    + str(i)
                    + "/hwmon/hwmon*/temp1_input"
                )
                file_names = glob.glob(path)
                if not file_names:
                    raise ValueError(self.ERROR_MSG_FILE_IO.format(path))
                self.hwmon_path.append(file_names[0])

    def _get_nth_temp(self, index: int) -> float:
        """Get the temperature of the 'nth' element in the hwmon list.

        Args:
            index (int): index in hwmon list

        Returns:
            float: temperature value

        Raises:
            FileNotFoundError:  file not found
            IOError:            file cannot be opened
            ValueError:         invalid index
        """
        value: float  # Temperature value

        try:
            with open(self.hwmon_path[index], encoding="UTF-8") as f:
                value = float(f.read()) / 1000
        except (OSError, FileNotFoundError, ValueError) as e:
            raise e
        return value


class Service:
    """Service class contains all resources/functions for the execution."""

    config: configparser.ConfigParser  # Instance for a parsed configuration
    log: Log  # Instance for a Log class
    ipmi: Ipmi  # Instance for an Ipmi class
    cpu_zone: CpuZone  # Instance for a CPU Zone fan controller class
    cpu2_zone: CpuZone  # Instance for a CPU Zone fan controller class
    cpu_zone_enabled: bool  # CPU zone fan controller enabled
    cpu2_zone_enabled: bool  # CPU zone fan controller enabled

    def exit_func(self) -> None:
        """This function is called at exit (in case of exceptions or runtime errors cannot be handled), and it switches
        all fans back to rhw default speed 100%, in order to avoid system overheating while `smfc` is not running.
        """
        # Configure fans.
        if hasattr(self, "ipmi"):
            self.ipmi.set_fan_level(Ipmi.CPU_ZONE, 100)
            self.ipmi.set_fan_level(Ipmi.CPU2_ZONE, 100)
            if hasattr(self, "log"):
                self.log.msg(
                    Log.LOG_INFO,
                    "smfc terminated: all fans are switched back to the 100% speed.",
                )

        # Unregister this function.
        atexit.unregister(self.exit_func)

    def check_dependencies(self) -> str:
        """Check run-time dependencies of smfc:

              - ipmitool command
              - if CPU zone enabled: coretemp or k10temp kernel module
              - if HD zone enabled: drivetemp kernel module or hddtemp command

        Returns:
            (str): error string:

                - empty: dependencies are OK
                - otherwise: the error message

        """
        path: str

        # Load list of kernel modules.
        with open("/proc/modules", encoding="utf-8") as file:
            modules = file.read()

        # Check kernel modules for CPUs
        if self.cpu_zone_enabled:
            if "coretemp" not in modules and "k10temp" not in modules:
                return "ERROR: coretemp or k10temp kernel module is not loaded!"

        # All required run-time dependencies seems to be available.
        return ""

    def run(self) -> None:
        """Run function: main execution function of the systemd service."""
        app_parser: argparse.ArgumentParser  # Instance for an ArgumentParser class
        parsed_results: argparse.Namespace  # Results of parsed command line arguments
        old_mode: int  # Old IPMI fan mode

        # Register the emergency exit function for service termination.
        atexit.register(self.exit_func)

        # Parse the command line arguments.
        app_parser = argparse.ArgumentParser()
        app_parser.add_argument(
            "-c",
            action="store",
            dest="config_file",
            default="smfc.conf",
            help="configuration file",
        )
        app_parser.add_argument(
            "-v", action="version", version="%(prog)s " + version_str
        )
        app_parser.add_argument(
            "-l",
            type=int,
            choices=[0, 1, 2, 3, 4],
            default=1,
            help="log level: 0-NONE, 1-ERROR(default), 2-CONFIG, 3-INFO, 4-DEBUG",
        )
        app_parser.add_argument(
            "-o",
            type=int,
            choices=[0, 1, 2],
            default=2,
            help="log output: 0-stdout, 1-stderr, 2-syslog(default)",
        )
        # Note: the argument parser can exit here with the following exit codes:
        # 0 - printing help or version text
        # 2 - invalid parameter
        parsed_results = app_parser.parse_args()

        # Create a Log class instance (in theory this cannot fail).
        try:
            self.log = Log(parsed_results.l, parsed_results.o)
        except ValueError as e:
            print(f"ERROR: {e}.", flush=True, file=sys.stdout)
            sys.exit(5)

        if self.log.log_level >= Log.LOG_CONFIG:
            self.log.msg(Log.LOG_CONFIG, "Command line arguments:")
            self.log.msg(
                Log.LOG_CONFIG, f'   original arguments: {" ".join(sys.argv[:])}'
            )
            self.log.msg(
                Log.LOG_CONFIG, f"   parsed config file = {parsed_results.config_file}"
            )
            self.log.msg(Log.LOG_CONFIG, f"   parsed log level = {parsed_results.l}")
            self.log.msg(Log.LOG_CONFIG, f"   parsed log output = {parsed_results.o}")

        # Parse and load configuration file.
        self.config = configparser.ConfigParser()
        if not self.config or not self.config.read(parsed_results.config_file):
            self.log.msg(
                Log.LOG_ERROR,
                f"Cannot load configuration file ({parsed_results.config_file})",
            )
            sys.exit(6)
        self.cpu_zone_enabled = self.config[CpuZone.CS_CPU_ZONE].getboolean(
            CpuZone.CV_CPU_ZONE_ENABLED, fallback=False
        )
        self.cpu2_zone_enabled = self.config[CpuZone.CS_CPU2_ZONE].getboolean(
            CpuZone.CV_CPU_ZONE_ENABLED, fallback=False
        )
        self.log.msg(
            Log.LOG_DEBUG, f"Configuration file ({parsed_results.config_file}) loaded"
        )

        # Check run-time dependencies (commands, kernel modules).
        error_msg = self.check_dependencies()
        if error_msg:
            self.log.msg(Log.LOG_ERROR, error_msg)
            sys.exit(4)

        # Create an Ipmi class instances and set required IPMI fan mode.
        try:
            self.ipmi = Ipmi(self.log, self.config)
            old_mode = self.ipmi.get_fan_mode()
        except (ValueError, FileNotFoundError) as e:
            self.log.msg(Log.LOG_ERROR, f"{e}.")
            sys.exit(7)
        self.log.msg(
            Log.LOG_DEBUG,
            f"Old IPMI fan mode = {self.ipmi.get_fan_mode_name(old_mode)}",
        )
        if old_mode != Ipmi.FULL_MODE:
            self.ipmi.set_fan_mode(Ipmi.FULL_MODE)
            self.log.msg(
                Log.LOG_DEBUG,
                f"New IPMI fan mode = {self.ipmi.get_fan_mode_name(Ipmi.FULL_MODE)}",
            )

        # Create an instance for CPU zone fan controller if enabled.
        # self.cpu_zone = None
        if self.cpu_zone_enabled:
            self.log.msg(Log.LOG_DEBUG, "CPU zone fan controller enabled")
            self.cpu_zone = CpuZone(
                self.log, CpuZone.CS_CPU_ZONE, self.ipmi, self.config
            )

        # Create an instance for CPU zone fan controller if enabled.
        # self.cpu2_zone = None
        if self.cpu2_zone_enabled:
            self.log.msg(Log.LOG_DEBUG, "CPU zone fan controller enabled")
            self.cpu2_zone = CpuZone(
                self.log, CpuZone.CS_CPU2_ZONE, self.ipmi, self.config
            )

        wait = self.cpu_zone.polling / 2
        self.log.msg(Log.LOG_DEBUG, f"Main loop wait time = {wait} sec")

        # Main execution loop.
        while True:
            if self.cpu_zone_enabled:
                self.cpu_zone.run()
            if self.cpu2_zone_enabled:
                self.cpu2_zone.run()
            time.sleep(wait)


if __name__ == "__main__":
    service = Service()
    service.run()

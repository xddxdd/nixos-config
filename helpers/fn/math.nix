{lib, ...}: rec {
  pi = 3.1415926;
  epsilon = 0.0000000001;

  parseFloat = builtins.fromJSON;

  floor = x: let
    tmp = lib.toInt (builtins.head (lib.splitString "." (builtins.toString x)));
  in
    if x < 0 && lib.hasInfix "." (builtins.toString x)
    then tmp - 1
    else tmp;

  div = a: b:
    if a < 0
    then 0 - div (0 - a) b
    else if b < 0
    then 0 - div a (0 - b)
    else floor (1.0 * a / b);

  mod = a: b:
    if a < 0
    then mod (b - mod (0 - a) b) b
    else a - b * (div a b);

  pow = x: times: let
    helper = tmp: times:
      if times > 0
      then helper (tmp * x) (times - 1)
      else tmp;
  in
    helper 1.0 times;

  factorial = x: let
    helper = tmp: times:
      if times > 0
      then helper (tmp * times) (times - 1)
      else tmp;
  in
    helper 1.0 x;

  # Taylor series: for x >= 0, atan(x) = x - x^3/3! + x^5/5!
  sin = x: let
    x_shrunk = mod (1.0 * x) (2 * pi);

    iterations = 10;

    step = i:
      (
        if mod i 2 == 0
        then -1.0
        else 1.0
      )
      * (pow x_shrunk (i * 2 - 1))
      / (factorial (i * 2 - 1));

    helper = tmp: times:
      if times > 0
      then helper (tmp + step times) (times - 1)
      else tmp;
  in
    if x < 0
    then -sin (0 - x)
    else helper 0 iterations;

  cos = x: sin (0.5 * pi - x);

  tan = x: (sin x) / (cos x);

  # https://stackoverflow.com/questions/42537957/fast-accurate-atan-arctan-approximation-algorithm
  # Taylor series: for 0 <= x <= 1, atan(x) = x - x^3/3 + x^5/5
  atan = x: let
    iterations = 10;

    step = i:
      (
        if mod i 2 == 0
        then -1
        else 1
      )
      * (pow (1.0 * x) (i * 2 - 1))
      / (i * 2 - 1);

    helper = tmp: times:
      if times > 0
      then helper (tmp + step times) (times - 1)
      else tmp;
  in
    if x < 0
    then atan (0 - x)
    else if x > 1
    then pi / 2 - atan (1 / x)
    else helper 0 iterations;

  deg2rad = x: x * pi / 180;

  sqrt = x: let
    iterations = 10;
    step = tmp: (tmp + x / tmp) / 2;
    helper = tmp: times:
      if times > 0
      then helper (step tmp) (times - 1)
      else tmp;
  in
    if x < epsilon
    then 0
    else helper (1.0 * x) iterations;

  # https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
  haversine = lat1: lon1: lat2: lon2: let
    radius = 6371000;
    rad_lat = deg2rad ((1.0 * lat2) - (1.0 * lat1));
    rad_lon = deg2rad ((1.0 * lon2) - (1.0 * lon1));
    a = (sin (rad_lat / 2)) * (sin (rad_lat / 2)) + (cos (deg2rad (1.0 * lat1))) * (cos (deg2rad (1.0 * lat2))) * (sin (rad_lon / 2)) * (sin (rad_lon / 2));
    c = 2 * atan ((sqrt a) / (sqrt (1 - a)));
  in
    radius * c;
}

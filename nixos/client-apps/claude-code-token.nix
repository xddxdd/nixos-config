{ inputs, ... }:
{
  age.secrets.claude-code-token = {
    file = inputs.secrets + "/claude-code-anyrouter.age";
    group = "lantian";
    mode = "0440";
  };
}

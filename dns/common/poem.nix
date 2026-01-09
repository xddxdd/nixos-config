{ lib, ... }:
let
  poet =
    poem: isIPv6: prefix: first:
    let
      idxToString = if isIPv6 then lib.toHexString else builtins.toString;
      idx = n: "${prefix}${idxToString (first + n)}";
    in
    lib.imap0 (i: v: {
      recordType = "PTR";
      name = idx i;
      target = "${lib.removeSuffix "." v}.";
    }) poem;
in
{
  common.poem = poet [
    "one.should.uphold.his.countrys.interest.with.his.life"
    "he.should.not.do.things"
    "just.to.pursue.his.personal.gains"
    "and.he.should.not.evade.responsibilities"
    "for.fear.of.personal.loss"
  ];

  common.manosaba = poet [
    "该对艾玛☺️🌸说🗣什么😢才好.该用什么🫨表情🥺见她"
    "就算我承认😣.我的杀意🗡🗡和憎恶😡😡.一切都是错❌❌❌❌的"
    "但事到如今😢😢😢"
    "我所做的事️🌺😠🫸😱🌸也不会一笔勾销😖"
    "即便如此😠.即便如此我也想向她道歉🫂😢.我错了😭😭😭"
    "我🌺🐷👈根本就没有什么正确❌❌❌🥺🥺！"
    "我忍住哭泣🥺🥺的冲动.用力咬紧嘴唇🫦🫦"
    "即使这样😭.艾玛☺️🌸还会笑🥰🥰着对我😱吗？"
    "但我很了解她☺️🌸.应该是😢😢很了解她的☺️🌸"
    "她一定会笑着🥰🥰🥰呼唤我🌺😢的名字😞的吧"
    "没关系👋👋的🥰🌸.希罗🤗🌸"
    "因为我们🌺☺💓☺️🌸️.是朋友😘😘😘啊💪💪"
    "🥰🥰🥰我仿佛听见艾玛😘🌸"
    "说这句话🫦的声音🗣🗣就在耳边🌸😘🥰🌺"
    "同时电梯🛗也到达了.电梯🛗门🚪打开"
    "🦋😵🗡🦋"
    "呜～↗噔↗噔↘噔↗噔↗噔↘噔↗噔噔噔↗"
    "———😨"
    "啊啊啊啊啊啊啊啊啊啊——😨😱😭😭😭"
  ];
}

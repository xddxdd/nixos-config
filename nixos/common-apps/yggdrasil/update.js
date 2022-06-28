// Run on https://publicpeers.neilalexander.dev/
(function () {
  let elems = document.getElementsByTagName("tr");
  let result = {};
  let country = null;
  for (let i = 0; i < elems.length; i++) {
    if (elems[i].className == "statusgood" || elems[i].className == "statusavg") {
      let innerElems= elems[i].getElementsByTagName("td");
      let address = null;
      for (let j = 0; j < innerElems.length; j++) {
        if (innerElems[j].id == "address") {
          let thisAddress = innerElems[j].innerText;
          if (!thisAddress.startsWith("tls://")) continue;
          address = thisAddress;
          break;
        }
      }
      if (address == null) continue;
      if (country != null) {
        result[country].push(address);
      }
    } else if (elems[i].className == "") {
      country = elems[i].innerText;
      result[country] = [];
    }
  }
  document.body.innerHTML = "<pre>" + JSON.stringify(result, null, 2) + "</pre>";
})();

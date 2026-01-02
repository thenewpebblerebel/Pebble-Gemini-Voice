var GEMINI_KEY = "AIzaSyCPsdhVRgweMTn5027Bx8zouRYj_gVfew8";

Pebble.addEventListener('appmessage', function(e) {
  // 1. Handle "Stop" (Interruption)
  if (e.payload.StopAudio) {
    window.speechSynthesis.cancel();
    return;
  }

  // 2. Handle "Query" (When you speak to the watch)
  if (e.payload.Query) {
    var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + GEMINI_KEY;
    var request = new XMLHttpRequest();
    request.open("POST", url, true);
    request.setRequestHeader("Content-Type", "application/json");

    request.onload = function() {
      var json = JSON.parse(request.responseText);
      var aiText = json.candidates[0].content.parts[0].text;

      // Send response to watch screen
      Pebble.sendAppMessage({ "Response": aiText }, function() {
        // Trigger a chime on the watch speaker
        Pebble.sendAppMessage({ "PlayAudio": 1 });
        // Use the phone's voice to read the answer (Relay mode)
        var msg = new SpeechSynthesisUtterance(aiText);
        window.speechSynthesis.speak(msg);
      });
    };
    request.send(JSON.stringify({"contents": [{"parts": [{"text": e.payload.Query}]}]}));
  }
});
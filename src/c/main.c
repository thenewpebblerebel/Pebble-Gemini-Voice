#include <pebble.h>

static Window *s_window;
static TextLayer *s_text_layer;
static DictationSession *s_dictation;
static char s_response_buffer[512];

// This runs when the AI replies
static void in_received_handler(DictionaryIterator *iter, void *context) {
  Tuple *t_res = dict_find(iter, MESSAGE_KEY_Response);
  if (t_res) {
    snprintf(s_response_buffer, sizeof(s_response_buffer), "%s", t_res->value->cstring);
    text_layer_set_text(s_text_layer, s_response_buffer);
  }
  
  // Play chime on Time 2 speaker
  if (dict_find(iter, MESSAGE_KEY_PlayAudio)) {
    #ifdef PBL_PLATFORM_EMERY
      smart_audio_play_system_sound(SMART_AUDIO_VOICE_ASSISTANT_REPLY);
    #endif
  }
}

// What happens when you finish speaking
static void dict_callback(DictationSession *s, DictationSessionStatus status, char *transcription, void *context) {
  if (status == DictationSessionStatusSuccess) {
    text_layer_set_text(s_text_layer, "Gemini is thinking...");
    DictionaryIterator *iter;
    app_message_outbox_begin(&iter);
    dict_write_cstring(iter, MESSAGE_KEY_Query, transcription);
    app_message_outbox_send();
  }
}

// The "Long Press" logic
static void select_long_click_handler(ClickRecognizerRef recognizer, void *context) {
  DictionaryIterator *iter;
  app_message_outbox_begin(&iter);
  dict_write_uint8(iter, MESSAGE_KEY_StopAudio, 1); // Kill old audio
  app_message_outbox_send();

  vibes_short_pulse();
  dictation_session_start(s_dictation);
}

static void click_config_provider(void *context) {
  window_long_click_subscribe(BUTTON_ID_SELECT, 500, select_long_click_handler, NULL);
}

static void prv_window_load(Window *window) {
  s_text_layer = text_layer_create(layer_get_bounds(window_get_root_layer(window)));
  text_layer_set_text(s_text_layer, "HOLD Select to talk to Gemini");
  text_layer_set_overflow_mode(s_text_layer, GTextOverflowModeWordWrap);
  layer_add_child(window_get_root_layer(window), text_layer_get_layer(s_text_layer));
}

static void prv_init(void) {
  s_window = window_create();
  window_set_click_config_provider(s_window, click_config_provider);
  window_set_window_handlers(s_window, (WindowHandlers) { .load = prv_window_load });
  
  app_message_register_inbox_received(in_received_handler);
  app_message_open(512, 512);
  s_dictation = dictation_session_create(512, dict_callback, NULL);
  
  window_stack_push(s_window, true);
}

int main(void) {
  prv_init();
  app_event_loop();
}
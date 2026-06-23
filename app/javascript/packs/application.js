// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import $ from 'jquery';
import "../../../vendor/assets/javascripts/semantic.min.js";
import InitManager from '../utils/init_manager';
window.$ = window.jQuery = $;
Rails.start()
Turbolinks.start();
ActiveStorage.start();
window.InitManager = InitManager;
// События
function initialize() {
  initSemanticUI();
}

// Обновляем обработчики событий
document.addEventListener('turbolinks:load', initialize);

// Функция инициализации Semantic UI
function initSemanticUI() {
  if ($('.ui.dropdown').length) $('.ui.dropdown').dropdown();
  if ($('.ui.checkbox').length) $('.ui.checkbox').checkbox();
  if ($('.ui.progress').length) $('.ui.progress').progress();
  if ($('.menu .item').length) $('.menu .item').tab();
  if ($('.ui.modal').length) $('.ui.modal').modal();
}
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  setTimeout(() => InitManager.runAll(), 1);
}
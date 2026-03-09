const InitManager = {
  _initialized: new Set(),
  _executed: new Set(),
  _functions: new Map(),
  _turbolinksFired: false,

  // Добавляет функцию
  add(fn) {
    const fnName = fn.name || this._getFunctionName(fn);
    
    if (this._initialized.has(fnName)) {
      return false;
    }
    
    this._functions.set(fnName, fn);
    this._initialized.add(fnName);
    
    if (this._turbolinksFired && !this._executed.has(fnName)) {
      fn();
      this._executed.add(fnName);
    }
    
    return true;
  },

  // Выполняет все невыполненные функции
  runNew() {
    this._functions.forEach((fn, name) => {
      if (!this._executed.has(name)) {
        fn();
        this._executed.add(name);
      }
    });
  },

  // Выполняет все функции
  runAll() {
    this._functions.forEach((fn, name) => {
      fn();
      this._executed.add(name);
    });
  },

  // Сбрасывает для новой страницы
  resetForNewPage() {
    this._executed.clear();
  },

  // Полная очистка
  reset() {
    this._initialized.clear();
    this._executed.clear();
    this._functions.clear();
  },

  _getFunctionName(fn) {
    const match = fn.toString().match(/[A-Za-z0-9_]+(?=\s*=\s*\(?[^)]*\)?\s*=>)/);
    return match ? match[0] : 'anonymous';
  },

  has(fn) {
    const fnName = fn.name || this._getFunctionName(fn);
    return this._initialized.has(fnName);
  },

  wasExecuted(fn) {
    const fnName = fn.name || this._getFunctionName(fn);
    return this._executed.has(fnName);
  },

  list() {
    return {
      all: Array.from(this._initialized),
      executed: Array.from(this._executed),
      pending: Array.from(this._initialized).filter(x => !this._executed.has(x))
    };
  }
};

document.addEventListener('turbolinks:load', () => {
  InitManager._turbolinksFired = true;
  InitManager.resetForNewPage();
  InitManager.runNew();
});

document.addEventListener('DOMContentLoaded', () => {
  if (!InitManager._turbolinksFired) {
    InitManager.resetForNewPage();
    InitManager.runNew();
  }
});

document.addEventListener('association:after-insert', () => {
  setTimeout(() => InitManager.runNew(), 50);
});

export default InitManager;
export function userAgent() {
  return window.navigator.userAgent;
}

export function isIOS() {
  return /iPhone|iPad|iPod/i.test(this.userAgent);
}

export function isAndroid() {
  return /Android/i.test(this.userAgent);
}

export function isMobileDevice() {
  return /Android|webOS|iPhone|iPad|BlackBerry|IEMobile|Opera Mini/i.test(userAgent());
}

export function isWindows() {
  return /Windows NT/i.test(this.userAgent);
}

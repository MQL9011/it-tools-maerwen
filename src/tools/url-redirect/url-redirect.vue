<script setup lang="ts">
import { isNotThrowing } from '@/utils/boolean';

const BLOCKED_PROTOCOLS = new Set(['javascript:', 'data:', 'vbscript:', 'blob:']);

const urlInput = ref('');

function normalizeUrl(raw: string): string {
  const trimmed = raw.trim();
  if (!trimmed) {
    return '';
  }
  // Keep explicit schemes (http, https, dtmapp, mailto, ...) as-is.
  if (/^[a-zA-Z][a-zA-Z\d+\-.]*:/.test(trimmed)) {
    return trimmed;
  }
  return `https://${trimmed}`;
}

function getProtocol(url: string): string | undefined {
  return url.match(/^([a-zA-Z][a-zA-Z\d+\-.]*:)/)?.[1]?.toLowerCase();
}

function isOpenableUrl(raw: string): boolean {
  const url = normalizeUrl(raw);
  if (!url) {
    return false;
  }

  const protocol = getProtocol(url);
  if (!protocol || BLOCKED_PROTOCOLS.has(protocol)) {
    return false;
  }

  // http(s) must parse as a real URL.
  if (protocol === 'http:' || protocol === 'https:') {
    return isNotThrowing(() => Boolean(new URL(url)));
  }

  // Custom schemes (dtmapp://...) — don't require WHATWG URL host rules.
  return url.length > protocol.length;
}

const normalizedUrl = computed(() => normalizeUrl(urlInput.value));
const isValidUrl = computed(() => isOpenableUrl(urlInput.value));
const isCustomScheme = computed(() => {
  if (!isValidUrl.value) {
    return false;
  }
  return !/^https?:/i.test(normalizedUrl.value);
});

const urlValidationRules = [
  {
    validator: (value: string) => !value.trim() || isOpenableUrl(value),
    message: 'Invalid URL',
  },
];

function openCustomScheme(url: string) {
  // Some Android WebViews only react to iframe navigation for app schemes.
  try {
    const iframe = document.createElement('iframe');
    iframe.style.cssText = 'display:none;width:0;height:0;border:0;position:absolute;left:-9999px';
    iframe.src = url;
    document.body.appendChild(iframe);
    window.setTimeout(() => iframe.remove(), 2500);
  }
  catch {
    // ignore
  }

  // Top-level navigation under a real user gesture is the most reliable way
  // to hand off custom schemes to the OS/app on real phones.
  // Programmatic <a>.click() is frequently blocked by mobile browsers.
  window.location.href = url;
}

function openUrl(event?: Event) {
  if (!isValidUrl.value) {
    return;
  }

  const url = normalizedUrl.value;

  if (isCustomScheme.value) {
    // Keep native <a href> default; also force top-level navigation.
    openCustomScheme(url);
    return;
  }

  event?.preventDefault?.();
  window.open(url, '_blank', 'noopener,noreferrer');
}
</script>

<template>
  <c-card>
    <c-input-text
      v-model:value="urlInput"
      label="URL:"
      placeholder="https://example.com 或 dtmapp://path"
      raw-text
      autofocus
      :validation-rules="urlValidationRules"
      @keydown.enter="openUrl"
    />

    <div mt-4 flex flex-col items-center gap-3>
      <!-- Custom scheme: real <a href> so the browser treats it as a trusted navigation -->
      <c-button
        type="primary"
        :disabled="!isValidUrl"
        :href="isCustomScheme && isValidUrl ? normalizedUrl : undefined"
        @click="openUrl"
      >
        跳转打开
      </c-button>

      <a
        v-if="isCustomScheme && isValidUrl"
        :href="normalizedUrl"
        class="fallback-link"
      >
        若按钮无效，点此直接打开
      </a>
    </div>

    <p v-if="normalizedUrl && isValidUrl" mt-3 text-center opacity-70>
      {{ isCustomScheme ? '将唤起应用打开：' : '将在新标签页打开：' }}{{ normalizedUrl }}
    </p>

    <p v-if="isCustomScheme" mt-2 text-center text-sm opacity-60>
      需已安装并注册该协议的 App；微信/企业微信内置浏览器通常会拦截，请用系统 Safari / Chrome 打开本页再试。
    </p>
  </c-card>
</template>

<style lang="less" scoped>
.fallback-link {
  color: var(--primary-color, #18a058);
  text-decoration: underline;
  word-break: break-all;
  text-align: center;
  max-width: 100%;
}
</style>

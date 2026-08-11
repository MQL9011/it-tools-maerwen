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

function isOpenableUrl(raw: string): boolean {
  const url = normalizeUrl(raw);
  if (!url) {
    return false;
  }
  return isNotThrowing(() => {
    const parsed = new URL(url);
    return !BLOCKED_PROTOCOLS.has(parsed.protocol.toLowerCase());
  });
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

function openUrl() {
  if (!isValidUrl.value) {
    return;
  }

  const url = normalizedUrl.value;

  // Custom schemes (e.g. dtmapp://) are often ignored by window.open.
  // A user-gesture <a> click is the reliable way to hand off to the OS/app.
  if (isCustomScheme.value) {
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.rel = 'noopener noreferrer';
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    return;
  }

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

    <div mt-4 flex justify-center>
      <c-button type="primary" :disabled="!isValidUrl" @click="openUrl">
        跳转打开
      </c-button>
    </div>

    <p v-if="normalizedUrl && isValidUrl" mt-3 text-center opacity-70>
      {{ isCustomScheme ? '将唤起应用打开：' : '将在新标签页打开：' }}{{ normalizedUrl }}
    </p>
  </c-card>
</template>

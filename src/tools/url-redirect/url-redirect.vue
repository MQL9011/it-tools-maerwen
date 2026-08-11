<script setup lang="ts">
import { isNotThrowing } from '@/utils/boolean';

const urlInput = ref('');

function normalizeUrl(raw: string): string {
  const trimmed = raw.trim();
  if (!trimmed) {
    return '';
  }
  if (/^[a-zA-Z][a-zA-Z\d+\-.]*:/.test(trimmed)) {
    return trimmed;
  }
  return `https://${trimmed}`;
}

function isHttpUrl(raw: string): boolean {
  const url = normalizeUrl(raw);
  if (!url) {
    return false;
  }
  return isNotThrowing(() => {
    const parsed = new URL(url);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  });
}

const normalizedUrl = computed(() => normalizeUrl(urlInput.value));
const isValidUrl = computed(() => isHttpUrl(urlInput.value));

const urlValidationRules = [
  {
    validator: (value: string) => !value.trim() || isHttpUrl(value),
    message: 'Invalid URL',
  },
];

function openUrl() {
  if (!isValidUrl.value) {
    return;
  }
  window.open(normalizedUrl.value, '_blank', 'noopener,noreferrer');
}
</script>

<template>
  <c-card>
    <c-input-text
      v-model:value="urlInput"
      label="URL:"
      placeholder="https://example.com 或 example.com"
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
      将在新标签页打开：{{ normalizedUrl }}
    </p>
  </c-card>
</template>

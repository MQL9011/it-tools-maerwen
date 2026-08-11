import { ExternalLink } from '@vicons/tabler';
import { defineTool } from '../tool';
import { translate } from '@/plugins/i18n.plugin';

export const tool = defineTool({
  name: translate('tools.url-redirect.title'),
  path: '/url-redirect',
  description: translate('tools.url-redirect.description'),
  keywords: ['url', 'redirect', 'jump', 'open', 'link', 'scheme', 'deep link', 'dtmapp', '跳转', '打开'],
  component: () => import('./url-redirect.vue'),
  icon: ExternalLink,
  createdAt: new Date('2026-08-11'),
});

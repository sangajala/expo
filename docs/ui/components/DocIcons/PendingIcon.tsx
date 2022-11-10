import { StatusWaitingIcon, theme } from '@expo/styleguide';

import { IconBase, DocIconProps } from './IconBase';

export const PendingIcon = ({ small }: DocIconProps) => (
  <IconBase Icon={StatusWaitingIcon} color={theme.status.warning} small={small} />
);

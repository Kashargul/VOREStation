import type { BooleanLike } from 'tgui-core/react';

import type { field } from '../GeneralRecords/types';

export type Data = {
  temp: { color: string; text: string } | null;
  scan: string | null;
  authenticated: BooleanLike;
  rank: string | null;
  screen: number | null;
  printing: BooleanLike;
  isAI: BooleanLike;
  isRobot: BooleanLike;
  records: record[] | undefined;
  general:
    | {
        fields: field[] | undefined;
        photos: string[] | undefined;
        has_photos: BooleanLike;
        empty: BooleanLike;
      }
    | undefined;
  security:
    | {
        fields: field[] | undefined;
        comments: { header: string; text: string }[] | undefined;
        empty: BooleanLike;
      }
    | undefined;
  modal: modalData;
};

type record = {
  ref: string;
  id: string;
  name: string;
  color: string;
  criminal: string;
};

export type modalData = {
  id: string;
  text: string;
  // biome-ignore lint/complexity/noBannedTypes: In this case we got any type of Object
  args: {};
  type: string;
};

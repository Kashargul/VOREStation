import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export const XenoarchArtifactAnalyzer = () => {
  return (
    <Window width={250} height={140}>
      <Window.Content>
        <XenoarchArtifactAnalyzerContent />
      </Window.Content>
    </Window>
  );
};

type Data = {
  owned_scanner: BooleanLike;
  scan_in_progress: BooleanLike;
};

const XenoarchArtifactAnalyzerContent = (props) => {
  const { act, data } = useBackend<Data>();

  const { owned_scanner, scan_in_progress } = data;

  if (!owned_scanner) {
    return (
      <Section title="No Scanner Detected">
        <Box color="bad">
          Warning: No scanner was detected. This machine requires a scanner to
          operate.
        </Box>
      </Section>
    );
  }

  if (scan_in_progress) {
    return (
      <Section title="Scan In Progress">
        Scanning...
        <Button mt={1} fluid icon="stop" onClick={() => act('scan')}>
          Cancel Scan
        </Button>
      </Section>
    );
  }

  return (
    <Section title="Artifact Analyzer">
      <Button fluid icon="search" onClick={() => act('scan')}>
        Begin Scan
      </Button>
    </Section>
  );
};

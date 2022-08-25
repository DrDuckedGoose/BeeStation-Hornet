import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, ScrollableBox, Flex, OrbitalMapComponent, OrbitalMapSvg, Input } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { toArray } from '../../common/collections';

export const TeleportControl = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        points,
    } = data;
    const lineStyle = {
        stroke: '#BBBBBB',
        strokeWidth: '2',
        };
    const velLineStyle = {
        stroke: '#00FF00',
        strokeWidth: '2',
        };
  return (
    <Window
        width={700}
        height={600}>
        <Window.Content fitted>
            <Box>
                <svg
                    position="absolute"
                    height="500px"
                    width="700px"
                    viewBox="0 0 100% 100%">
                    <defs>
                        <pattern id="grid" width={200} height={200} patternUnits="userSpaceOnUse">
                            <rect width={200} height={200} fill="url(#smallgrid)" />
                            <path d={"M 200 0 L 0 0 0 200"} fill="none" stroke="#4665DE" stroke-width="1" />
                        </pattern>
                        <pattern id="smallgrid" width={100} height={100} patternUnits="userSpaceOnUse">
                            <rect width={100} height={100} fill="#2B2E3B" />
                            <path d={"M 100 0 L 0 0 0 100"} fill="none" stroke="#4665DE" stroke-width="0.5" />
                        </pattern>
                    </defs>
                    <rect width="100%" height="100%" fill="url(#grid)" />
                    {points.map(point => <circle
                        cx={`${point.x+50}%`}
                        cy={`${point.y+50}%`}
                        r="1px"
                        stroke="rgba(255,255,255,255)"
                        stroke-width="1"
                        fill="rgba(255,255,255,255)" />)}                 
                </svg>
            </Box>
            <Box>
                Y = 
                <Input flow/>
            </Box>
        </Window.Content>
    </Window>
  );
};

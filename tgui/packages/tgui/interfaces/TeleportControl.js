import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, ScrollableBox, Flex, OrbitalMapComponent, OrbitalMapSvg } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { toArray } from '../../common/collections';
import { functionPlot } from "function-plot";

export const TeleportControl = (props, context) => {
    const lineStyle = {
        stroke: '#BBBBBB',
        strokeWidth: '2',
        };
    const velLineStyle = {
        stroke: '#00FF00',
        strokeWidth: '2',
        };
    const { act, data } = useBackend(context);
    const {
        points,
    } = data;
    const points_array = toArray(points);
  return (
    <Window
        width={1136}
        height={770}>
        <Window.Content fitted>
            <Box>
                {points_array.map(item => <Box>{item}</Box>)}
            </Box>
        </Window.Content>
    </Window>
  );
};

export const TeleportControlDisplay = (props, context) => {
    return(
        <Box
            width="370px"
            height="160px">
            <svg
                position="absolute"
                height="100%"
                viewBox="-100 -100 200 200">
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
                <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />
                <line
                    x1={0}
                    y1={0}
                    x2={50}
                    y2={50}
                    style={lineStyle} />
            </svg>
        </Box>
    );
};

import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, ScrollableBox, Flex, OrbitalMapComponent, OrbitalMapSvg, Input, Slider } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { toArray } from '../../common/collections';

export const TeleportControl = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        points,
        point_limit,
    } = data;

    const [
        xOffset,
        setXOffset,
      ] = useLocalState(context, 'xOffset', 0);
    const [
    yOffset,
    setYOffset,
    ] = useLocalState(context, 'yOffset', 0);

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
            <Box>{`${xOffset}`}</Box>
            <DraggableClickableControl
            position="absolute"
            value={1}
            dragMatrix={[-1, 0]}
            step={1}
            stepPixelSize={2 * 1}
            onDrag={(e, value) => {setXOffset(value)}}
            onClick={(e, value) => {}}
            updateRate={5}>
                {control => (
                    <svg
                        position="absolute"
                        height="500px"
                        width="700px"
                        viewBox="0 0 100% 100%">
                        <defs>
                            <pattern id="grid" width={32} height={32} patternUnits="userSpaceOnUse">
                                <rect width={32} height={32} fill="url(#smallgrid)" />
                                <path d={"M 32 0 L 0 0 0 32"} fill="none" stroke="#4665DE" stroke-width="1" />
                            </pattern>
                            <pattern id="smallgrid" width={16} height={16} patternUnits="userSpaceOnUse">
                                <rect width={16} height={16} fill="#2B2E3B" />
                                <path d={"M 16 0 L 0 0 0 16"} fill="none" stroke="#4665DE" stroke-width="0.5" />
                            </pattern>
                        </defs>
                        <rect width="100%" height="100%" fill="url(#grid)" />
                        {points.map(point => <circle
                            cx={`${point.x+359}`}
                            cy={`${point.y+251}`}
                            r="1px"
                            stroke="rgba(255,255,255,255)"
                            stroke-width="1"
                            fill="rgba(255,255,255,255)" />)}                 
                    </svg>
                )}
            </DraggableClickableControl>
            <Box flow>
                <Input flow
                onChange={(e, value) => {act("compile_formula", {points: compile_formula(value)})}}/>
                <Slider value={point_limit} minValue={0} maxValue={100} onChange={(e, value) => {act("input_limit", {limit: value})}}/>
            </Box>
        </Window.Content>
    </Window>
  );
};

function compile_formula(value){
    const points = []
    for(let i = 0; i < 800; i+=8){
        let text = value.replace(/x/g, i);
        points[i] = eval(text)
    }
    return points;
}

function sin(value){
    return Math.sin(value);
}

function cos(value){
    return Math.cos(value);
}

function tan(value){
    return Math.tan(value);
}

function abs(value){
    return Math.abs(value);
}

function sqrt(value){
    return Math.sqrt(value);
}

function log (value){
    return Math.log(value);
}

function inverse (value){
    return Math.inverse(value);
}

function exp (value){
    return Math.exp(value);
}

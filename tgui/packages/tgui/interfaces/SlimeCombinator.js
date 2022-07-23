import { map, toArray } from 'common/collections';
import { classes } from 'common/react';
import { render } from 'inferno';
import { useBackend } from '../backend';
import { Box, Tabs, Section, Flex, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, Table, Dimmer, Divider, ProgressBar } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { getWindowSize, recallWindowGeometry } from '../drag';
import { Window } from '../layouts';

export const SlimeCombinator = (props, context) => {
	const { act, data } = useBackend(context);
	const current_tab=(data.tab);
	const available=(data.availability);
	const instability=data.instability
return (
	<Window
	width={450}
	height={460}>
	<Window.Content scrollable>
		{!available && (<Dimmer><Box>Resetting simulation... <Icon name="cog" spin={true}/></Box></Dimmer>)}
		<Section>
			<ProgressBar value={(100-instability)*0.01} textAlign="center" ranges={{good: [0.5, Infinity],average: [0.25, 0.5],bad: [-Infinity, 0.25]}}>Stability</ProgressBar>
		</Section>
		{current_tab === "Select-Initial" && <SlimeOptions_Parent/>}
		{current_tab === "Promote-Outcomes" && <SlimeOptions_Child/>}
	</Window.Content>
	</Window>
);
};

const SlimeOptions_Parent = (props, context) => {
	const { act, data } = useBackend(context);
	const slimes=toArray(data.all_slimes);
	const parent_slimes=toArray(data.parent_slimes);
return (
	<Box>
		<Flex direction="column" align="center">
			{parent_slimes.length > 1 && (<Flex.Item p={0.5}>
				<Section>
					<Button onClick={() => act('combine-selected')}>
						Queue Simulation
					</Button>
				</Section>
			</Flex.Item>)}

			<Flex.Item p={0.5}>
				<Section>
				{parent_slimes.length ? parent_slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Selected Samples."}
				</Section>
			</Flex.Item>

			<Section>
				{slimes.length ? slimes.map(slime => (<Flex.Item p={0.5}><SlimeEntry slime = {slime} key = {slime}/></Flex.Item>)) : "No Present Samples."}
			</Section>
		</Flex>
	</Box>
);
};

const SlimeOptions_Child = (props, context) => {
	const { act, data } = useBackend(context);
	const parent_slimes=toArray(data.parent_slimes);
	const slimes=toArray(data.all_slimes);
return (
	<Box>
		<Flex direction="row" align="stretch" grow={1}>
			<Flex.Item p={0.5}>
				<Section>
					{slimes.length ? slimes.map(slime => (<Flex.Item p={0.5}><SlimeEntry slime = {slime} interactable={0} key = {slime}/></Flex.Item>)) : "No Present Samples."}
				</Section>
			</Flex.Item>

			<Flex direction="column" align="stretch" grow={1}>
				{parent_slimes.length > 1 && (<Flex.Item p={0.5}>
					<Section>
						<Button onClick={() => act('combine-selected')}>
							Requeue Simulation
						</Button>
					</Section>
				</Flex.Item>)}

				{parent_slimes.length === 1 && (<Flex.Item p={0.5}>
					<Section>
						<Button onClick={() => act('choose-selected')}>
							Select Sample
						</Button>
					</Section>
				</Flex.Item>)}

				<Flex.Item p={0.5}>
					<Section>
						{parent_slimes.length ? parent_slimes.map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Selected Samples."}
					</Section>
				</Flex.Item>

				<Flex.Item p={0.5}>
					<Section>
						<SlimeLitter/>
					</Section>
				</Flex.Item>
			</Flex>
		</Flex>
	</Box>
);
};

const SlimeEntry = (props, context) => {
	const { act, data } = useBackend(context);
	const {
		slime,
		interactable = true,
	} = props;
return (
	<Button tooltip={<div dangerouslySetInnerHTML={{ __html: slime.name}} selected={slime.selected}/>} onClick={() => interactable ? act('select-slime', {ref : slime.self_ref,}) : null}>
		<Box>
			{<img
			src={`data:image/jpeg;base64,${slime.img}`}
			height={48}
			width={48}
			image-rendering={"pixelated"}
			style={{
				'vertical-align': 'middle',
				'horizontal-align': 'middle',
			}} />}
		</Box>
	</Button>
);
};

const SlimeLitter= (props, context) => {
	const { act, data } = useBackend(context);
	const litter_slimes=toArray(data.litter_slimes);
return (
	<Box>
		<Table>
			<Table.Row>
				{litter_slimes.length ? litter_slimes.slice(0, 3).map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Litter Samples."}
			</Table.Row>
			<Table.Row>
				{litter_slimes.length ? litter_slimes.slice(3, 6).map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Litter Samples."}
			</Table.Row>
			<Table.Row>
				{litter_slimes.length ? litter_slimes.slice(6, 9).map(slime => (<SlimeEntry slime = {slime} key = {slime}/>)) : "No Litter Samples."}
			</Table.Row>
		</Table>
	</Box>
);
};

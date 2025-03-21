import { useBackend } from '../backend';
import { Button, Section, Box, Flex, Input, BlockQuote, Divider, Icon, Dimmer } from '../components';
import { Window } from '../layouts';

export const SeedEditor = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_plant,
  } = data;
  return (
    <Window width={600} height={500}>
      <Window.Content scrollable={0}>
        {inserted_plant ? <InUseBody /> : <EmptyBody /> }
      </Window.Content>
    </Window>
  );
};

const EmptyBody = (props) => {
  const { act, data } = useBackend();
  return (
    <Box textAlign='center'>
      Please Insert Seeds
    </Box>
  );
};

const InUseBody = (props) => {
  const { act, data } = useBackend();
  const {
    seeds_feature_data,
    inserted_plant,
    current_feature,
    disk_inserted,
    disk_feature_data,
    disk_trait_data,
  } = data;
  return (
    <Flex direction='row'>

      <Flex.Item width='35%' grow={1}>
        <Section>
          {inserted_plant}
          <Divider />
          <Flex direction='column'>
            {seeds_feature_data.map((feature_data) => (<PlantFeatureTab feature={feature_data} key={feature_data} />))}
            <Divider />
            {/* Isn't this confusing and terrible! I like it that way :blush: */}
            {disk_feature_data ? (<DiskFeatureTab data_set={disk_feature_data} />) : (disk_trait_data ? <DiskTraitTab data_set={disk_trait_data} /> : 'Empty Disk')}
          </Flex>
        </Section>
      </Flex.Item>

      <Flex.Item m={0.1} />

      <Flex.Item width='65%' height='100%' grow>
        <Section>
          <Box height={100} textAlign='center'>
            {current_feature ? <PlantDataTab /> : <EmptyBody />}
          </Box>
        </Section>
      </Flex.Item>

    </Flex>
  );
};

const DiskTraitTab = (props) => {
  const { act, data } = useBackend();
  const {
    data_set,
  } = props;
  return (
    <Box>
      <Button onClick={() => act('add_trait', { key : data_set["trait_ref"] })}>
        +
      </Button>
      <PlantTraitInstance title={data_set["trait_name"]} body={data_set["trait_desc"]} trait_key={data_set["trait_ref"]} key={data_set} />
    </Box>
  );
};

const DiskFeatureTab = (props) => {
  const { act, data } = useBackend();
  const {
    data_set,
  } = props;
  return (
    <Box>
      <Button onClick={() => act('add_feature', { key : data_set["key"] })}>
        +
      </Button>
      <PlantFeatureTab feature={data_set} />
    </Box>
  );
};

const PlantDataTab = (props) => {
  const { act, data } = useBackend();
  const {
    current_feature_data,
    current_feature_traits,
  } = data;
  return (
    <Flex direction="column">

      {current_feature_data.map((data_set) => (
        data_set["data_title"] ? <PlantDataInstance title={data_set["data_title"]} body={data_set["data_field"]} key={data_set} /> : <Divider key={data_set} />
      ))}

      <Flex.Item my={0.2} />

      {current_feature_traits ? current_feature_traits.map((data_set) => (
        <PlantTraitInstance title={data_set["trait_name"]} body={data_set["trait_desc"]} trait_key={data_set["trait_ref"]} key={data_set} />
      )) : `No Traits Found`}
    </Flex>
  );
};

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key } = props;
  return (
    <Flex.Item direction="row">
      <Box backgroundColor="purple">
        <b>{title}</b>
        <Divider />
        {body}
      </Box>
      <Button onClick={() => act('remove_trait', { key : trait_key })}>
        x
      </Button>
    </Flex.Item>
  );
};

const PlantDataInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body } = props;
  return (
    <Flex.Item>
      <b>{title}</b>: {body}
    </Flex.Item>
  );
};

const PlantFeatureTab = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const {
    current_feature,
  } = data;
  return (
    <Flex.Item>
      <Button width='100%' my={0.5} onClick={() => act('select_feature', { key : feature["key"] })}
        selected={feature["key"] === current_feature} >
        {`${feature["species_name"]} - ${feature["key"]}`}
      </Button>
      <Button onClick={() => act('remove_feature', { key : feature["key"] })}>
        x
      </Button>
    </Flex.Item>
  );
};

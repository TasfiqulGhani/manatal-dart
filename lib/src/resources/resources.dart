import '../base_resource.dart';
import '../client.dart';
import '../models.dart';

class CandidatesResource extends Resource {
  CandidatesResource(ManatalClient client) : super(client, '/candidates/');

  NestedResource activities(Object candidateId) =>
      NestedResource(client, path, candidateId, 'activities');

  NestedResource attachments(Object candidateId) =>
      NestedResource(client, path, candidateId, 'attachments');

  NestedResource educations(Object candidateId) =>
      NestedResource(client, path, candidateId, 'educations');

  NestedResource experiences(Object candidateId) =>
      NestedResource(client, path, candidateId, 'experiences');

  NestedResource matches(Object candidateId) =>
      NestedResource(client, path, candidateId, 'matches');

  NestedResource nationalities(Object candidateId) =>
      NestedResource(client, path, candidateId, 'nationalities');

  NestedResource notes(Object candidateId) =>
      NestedResource(client, path, candidateId, 'notes');

  NestedResource socialMedia(Object candidateId) =>
      NestedResource(client, path, candidateId, 'social-media');

  NestedResource skills(Object candidateId) =>
      NestedResource(client, path, candidateId, 'skills');

  NestedResource tags(Object candidateId) =>
      NestedResource(client, path, candidateId, 'tags');

  Future<dynamic> createSkillsBulk(
    Object candidateId,
    List<Object> skills,
  ) async {
    final result = await client.request(
      'POST',
      '$collection$candidateId/skills/bulk/',
      body: {'skills': skills},
    );
    return asObject(result);
  }
}

class JobsResource extends Resource {
  JobsResource(ManatalClient client) : super(client, '/jobs/');

  NestedResource activities(Object jobId) =>
      NestedResource(client, path, jobId, 'activities');

  NestedResource attachments(Object jobId) =>
      NestedResource(client, path, jobId, 'attachments');

  NestedResource matches(Object jobId) =>
      NestedResource(client, path, jobId, 'matches');

  NestedResource notes(Object jobId) =>
      NestedResource(client, path, jobId, 'notes');
}

class OrganizationsResource extends Resource {
  OrganizationsResource(ManatalClient client) : super(client, '/organizations/');

  NestedResource activities(Object organizationId) =>
      NestedResource(client, path, organizationId, 'activities');

  NestedResource attachments(Object organizationId) =>
      NestedResource(client, path, organizationId, 'attachments');

  NestedResource notes(Object organizationId) =>
      NestedResource(client, path, organizationId, 'notes');
}

class MatchesResource extends Resource {
  MatchesResource(ManatalClient client) : super(client, '/matches/');

  NestedResource activities(Object matchId) =>
      NestedResource(client, path, matchId, 'activities');

  NestedResource attachments(Object matchId) =>
      NestedResource(client, path, matchId, 'attachments');

  NestedResource notes(Object matchId) =>
      NestedResource(client, path, matchId, 'notes');
}

class ContactsResource extends Resource {
  ContactsResource(ManatalClient client) : super(client, '/contacts/');

  NestedResource activities(Object contactId) =>
      NestedResource(client, path, contactId, 'activities');

  NestedResource attachments(Object contactId) =>
      NestedResource(client, path, contactId, 'attachments');

  NestedResource notes(Object contactId) =>
      NestedResource(client, path, contactId, 'notes');
}

class UsersResource extends ReadOnlyResource {
  UsersResource(ManatalClient client) : super(client, '/users/');
}

class CurrenciesResource extends ReadOnlyResource {
  CurrenciesResource(ManatalClient client) : super(client, '/currencies/');
}

class LanguagesResource extends ReadOnlyResource {
  LanguagesResource(ManatalClient client) : super(client, '/languages/');
}

class NationalitiesResource extends ReadOnlyResource {
  NationalitiesResource(ManatalClient client) : super(client, '/nationalities/');
}

class IndustriesResource extends ReadOnlyResource {
  IndustriesResource(ManatalClient client) : super(client, '/industries/');
}

class JobPipelinesResource extends ReadOnlyResource {
  JobPipelinesResource(ManatalClient client) : super(client, '/job-pipelines/');
}

class MatchStagesResource extends ReadOnlyResource {
  MatchStagesResource(ManatalClient client) : super(client, '/match-stages/');
}

class SkillsResource extends Resource {
  SkillsResource(ManatalClient client) : super(client, '/skills/');

  Future<dynamic> createNames(List<String> names) =>
      create({'names': names});

  @override
  Future<dynamic> retrieve(Object id) {
    throw UnsupportedError('/skills/ does not support retrieve');
  }

  @override
  Future<dynamic> update(Object id, Map<String, dynamic> data) {
    throw UnsupportedError('/skills/ does not support update');
  }

  @override
  Future<void> delete(Object id) {
    throw UnsupportedError('/skills/ does not support delete');
  }
}

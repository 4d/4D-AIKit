# OpenAIAudioVoiceConsentListResult

The `OpenAIAudioVoiceConsentListResult` class contains the result of [listing consent recordings](OpenAIAudioVoiceConsentsAPI.md#list).

## Inherits

[OpenAIResult](OpenAIResult.md)

## Computed properties

| Property   | Type       | Description |
|------------|------------|-------------|
| `consents` | Collection | A collection of [OpenAIAudioVoiceConsent](OpenAIAudioVoiceConsent.md), or an empty collection if none found. |
| `first_id` | Text       | The ID of the first consent recording in the list, or an empty string. |
| `last_id`  | Text       | The ID of the last consent recording in the list, to use as `after`, or an empty string. |
| `has_more` | Boolean    | `True` if there are more consent recordings to fetch. |

## See also

- [OpenAIAudioVoiceConsentsAPI](OpenAIAudioVoiceConsentsAPI.md)
- [OpenAIAudioVoiceConsentListParameters](OpenAIAudioVoiceConsentListParameters.md)

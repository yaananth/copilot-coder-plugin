from redactor import SecretRedactor


def redact_assignment_output(response, output):
    return SecretRedactor(response.masks).mask(output)

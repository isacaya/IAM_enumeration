# Define colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print policy statements
print_policy_statements() {
    policy_arn=$1
    version_id=$2
    aws iam get-policy-version --policy-arn $policy_arn --version-id $version_id --query 'PolicyVersion.Document.Statement' --no-cli-pager
}

# List IAM roles
echo -e "${BLUE}IAM Role list${NC}"
aws iam list-roles --query 'Roles[].RoleName' --output text --no-cli-pager
echo

echo -e "${YELLOW}Enter the role name you want to check policies for${NC}"
echo -n "> "
read IAM_ROLE_NAME

echo -e "${BLUE}Role: ${IAM_ROLE_NAME}${NC}"
echo

echo -e "${GREEN}[Attached managed policies for the role]${NC}"
attached_policies=$(aws iam list-attached-role-policies --role-name $IAM_ROLE_NAME --query 'AttachedPolicies[].PolicyArn' --output text --no-cli-pager)
echo $(aws iam get-role --role-name $IAM_ROLE_NAME --query 'Role.Arn' --output text --no-cli-pager)
if [ -z "$attached_policies" ]; then
    echo -e "None"
else
    for policy_arn in $attached_policies; do
        echo -e "${GREEN}Policy ARN:${NC}\n$policy_arn"
        echo -e "${GREEN}Policy Description:${NC}\n$(aws iam get-policy --policy-arn $policy_arn --query 'Policy.Description' --output text --no-cli-pager)${NC}"
        echo -e "${GREEN}Policy statements:${NC}"
        print_policy_statements $policy_arn "v1"
    done
fi
echo

echo -e "${GREEN}[Inline policies for the role]${NC}"
inline_policies=$(aws iam list-role-policies --role-name $IAM_ROLE_NAME --query 'PolicyNames[]' --output text --no-cli-pager)
if [ -z "$inline_policies" ]; then
    echo -e "None"
else
    for policy_name in $inline_policies; do
        echo -e "${GREEN}Policy Name: $policy_name${NC}"
        echo -e "${GREEN}Policy statements:${NC}"
        aws iam get-role-policy --role-name $IAM_ROLE_NAME --policy-name $policy_name --query 'PolicyDocument.Statement' --no-cli-pager
    done
fi
echo

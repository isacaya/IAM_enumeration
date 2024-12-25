# Define colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print policy statement details
print_policy_statements() {
    policy_arn=$1
    version_id=$2
    aws iam get-policy-version --policy-arn $policy_arn --version-id $version_id --query 'PolicyVersion.Document.Statement' --no-cli-pager
}

# List IAM users
echo -e "${BLUE}IAM User list${NC}"
aws iam list-users --query 'Users[].UserName' --output text --no-cli-pager
echo

echo -e "${YELLOW}Enter the username you want to check policies for${NC}"
echo -n "> "
read IAM_USER_NAME

echo -e "${BLUE}User: ${IAM_USER_NAME}${NC}"
echo

echo -e "${GREEN}[Attached managed policies for the user]${NC}"
attached_policies=$(aws iam list-attached-user-policies --user-name $IAM_USER_NAME --query 'AttachedPolicies[].PolicyArn' --output text --no-cli-pager)
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

echo -e "${GREEN}[Inline policies for the user]${NC}"
inline_policies=$(aws iam list-user-policies --user-name $IAM_USER_NAME --query 'PolicyNames[]' --output text --no-cli-pager)
if [ -z "$inline_policies" ]; then
    echo -e "None"
else
    for policy_name in $inline_policies; do
        echo -e "${GREEN}Policy Name: $policy_name${NC}"
        echo -e "${GREEN}Policy statements:${NC}"
        aws iam get-user-policy --user-name $IAM_USER_NAME --policy-name $policy_name --query 'PolicyDocument.Statement' --no-cli-pager
    done
fi
echo

echo -e "${BLUE}Groups the user belongs to${NC}"
IAM_GROUPS=$(aws iam list-groups-for-user --user-name $IAM_USER_NAME --query 'Groups[].GroupName' --output text --no-cli-pager)

if [ -z "$IAM_GROUPS" ]; then
    echo -e "${YELLOW}The user does not belong to any groups${NC}"
else
    for group in $IAM_GROUPS; do
        echo -e "${BLUE}Group: ${group}${NC}"
        echo

        echo -e "${GREEN}[Attached managed policies for the group]${NC}"
        attached_policies=$(aws iam list-attached-group-policies --group-name $group --query 'AttachedPolicies[].PolicyArn' --output text --no-cli-pager)
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

        echo -e "${GREEN}[Inline policies for the group]${NC}"
        inline_policies=$(aws iam list-group-policies --group-name $group --query 'PolicyNames[]' --output text --no-cli-pager)
        if [ -z "$inline_policies" ]; then
            echo -e "None"
        else
            for policy_name in $inline_policies; do
                echo -e "${GREEN}Policy Name: $policy_name${NC}"
                echo -e "${GREEN}Policy statements:${NC}"
                aws iam get-group-policy --group-name $group --policy-name $policy_name --query 'PolicyDocument.Statement' --no-cli-pager
            done
        fi
        echo
    done
fi

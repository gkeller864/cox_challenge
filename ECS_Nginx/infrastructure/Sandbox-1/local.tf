locals {
  vpc_id                = data.aws_vpc.selected.id
  private_subnet        = data.aws_subnet.selected_private.id
  public_subnet         = data.aws_subnet.selected_public.id
}
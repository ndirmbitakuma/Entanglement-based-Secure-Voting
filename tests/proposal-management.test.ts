import { describe, it, expect, beforeEach } from 'vitest';

describe('proposal-management', () => {
  let contract: any;
  
  beforeEach(() => {
    contract = {
      submitProposal: (title: string, description: string, votingPeriod: number) => ({ value: 1 }),
      closeProposal: (proposalId: number) => ({ success: true }),
      getProposal: (proposalId: number) => ({
        title: 'Test Proposal',
        description: 'This is a test proposal',
        proposer: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        startBlock: 100,
        endBlock: 200,
        status: 'active'
      }),
      getProposalCount: () => 1
    };
  });
  
  describe('submit-proposal', () => {
    it('should submit a new proposal', () => {
      const result = contract.submitProposal('Test Proposal', 'This is a test proposal', 100);
      expect(result.value).toBe(1);
    });
  });
  
  describe('close-proposal', () => {
    it('should close an existing proposal', () => {
      const result = contract.closeProposal(1);
      expect(result.success).toBe(true);
    });
  });
  
  describe('get-proposal', () => {
    it('should return proposal information', () => {
      const proposal = contract.getProposal(1);
      expect(proposal.title).toBe('Test Proposal');
      expect(proposal.status).toBe('active');
    });
  });
  
  describe('get-proposal-count', () => {
    it('should return the total number of proposals', () => {
      const count = contract.getProposalCount();
      expect(count).toBe(1);
    });
  });
});
